#!/bin/bash
set -e

# ── Arguments from Terraform ───────────────
GRAFANA_ADMIN_USER=$1
GRAFANA_ADMIN_PASSWORD=$2
SLACK_WEBHOOK_URL=$3
SERVER_IP=$4

# ── Versions ───────────────────────────────
PROMETHEUS_VERSION="2.51.0"
LOKI_VERSION="2.9.5"
TEMPO_VERSION="2.4.1"
ALERTMANAGER_VERSION="0.27.0"
BLACKBOX_VERSION="0.24.0"
NODE_EXPORTER_VERSION="1.7.0"
PUSHGATEWAY_VERSION="1.7.0"

echo "========================================="
echo "  OpenProfile Observability Stack Setup  "
echo "========================================="

# ── Create service users ───────────────────
echo "[1/9] Creating service users..."
for user in prometheus loki tempo alertmanager blackbox node_exporter pushgateway; do
  id "$user" &>/dev/null || sudo useradd --no-create-home --shell /bin/false $user
done

# ── Create directories ─────────────────────
echo "[2/9] Creating directories..."
sudo mkdir -p /opt/{prometheus,loki,tempo,alertmanager,blackbox-exporter,node-exporter}
sudo mkdir -p /etc/prometheus/alerts
sudo mkdir -p /etc/{loki,tempo,alertmanager,otel-collector}
sudo mkdir -p /var/lib/{prometheus,loki,tempo,alertmanager}
sudo mkdir -p /var/lib/grafana/dashboards
sudo mkdir -p /etc/grafana/provisioning/{datasources,dashboards}

# ── Install Prometheus ─────────────────────
echo "[3/9] Installing Prometheus..."
cd /tmp

if ! command -v prometheus &> /dev/null; then
  wget -q "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"
  tar xf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
  sudo cp prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus /usr/local/bin/
  sudo cp prometheus-${PROMETHEUS_VERSION}.linux-amd64/promtool /usr/local/bin/
  sudo chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool
else
  echo "Prometheus already installed, skipping binary install..."
fi

# Always update configs
sudo cp /tmp/observability/prometheus.yml /etc/prometheus/prometheus.yml
sudo cp /tmp/observability/blackbox.yml /etc/prometheus/blackbox.yml
sudo cp /tmp/observability/alerts/*.yml /etc/prometheus/alerts/
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

if [ ! -f /etc/systemd/system/prometheus.service ]; then
  sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus Monitoring
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=always
RestartSec=5
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --storage.tsdb.retention.time=30d \
  --web.enable-lifecycle \
  --web.listen-address=0.0.0.0:9090

[Install]
WantedBy=multi-user.target
EOF
else
  echo "Prometheus service already exists, skipping..."
fi

# ── Install Node Exporter ──────────────────
echo "[4/9] Installing Node Exporter..."
cd /tmp

if ! command -v node_exporter &> /dev/null; then
  wget -q "https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
  tar xf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
  sudo cp node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/
  sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
else
  echo "Node Exporter already installed, skipping binary install..."
fi

if [ ! -f /etc/systemd/system/node-exporter.service ]; then
  sudo tee /etc/systemd/system/node-exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=always
RestartSec=5
ExecStart=/usr/local/bin/node_exporter \
  --collector.filesystem.mount-points-exclude='^/(sys|proc|dev|host|etc)($$|/)' \
  --web.listen-address=0.0.0.0:9100

[Install]
WantedBy=multi-user.target
EOF
else
  echo "Node Exporter service already exists, skipping..."
fi

# ── Install Pushgateway ────────────────────
echo "[5/9] Installing Pushgateway..."
cd /tmp

if ! command -v pushgateway &> /dev/null; then
  wget -q "https://github.com/prometheus/pushgateway/releases/download/v${PUSHGATEWAY_VERSION}/pushgateway-${PUSHGATEWAY_VERSION}.linux-amd64.tar.gz"
  tar xf pushgateway-${PUSHGATEWAY_VERSION}.linux-amd64.tar.gz
  sudo cp pushgateway-${PUSHGATEWAY_VERSION}.linux-amd64/pushgateway /usr/local/bin/
  sudo chown pushgateway:pushgateway /usr/local/bin/pushgateway
else
  echo "Pushgateway already installed, skipping binary install..."
fi

if [ ! -f /etc/systemd/system/pushgateway.service ]; then
  sudo tee /etc/systemd/system/pushgateway.service > /dev/null <<EOF
[Unit]
Description=Prometheus Pushgateway
Wants=network-online.target
After=network-online.target

[Service]
User=pushgateway
Group=pushgateway
Type=simple
Restart=always
RestartSec=5
ExecStart=/usr/local/bin/pushgateway \
  --web.listen-address=0.0.0.0:9091

[Install]
WantedBy=multi-user.target
EOF
else
  echo "Pushgateway service already exists, skipping..."
fi

# ── Install Alertmanager ───────────────────
echo "[6/9] Installing Alertmanager..."
cd /tmp

if ! command -v alertmanager &> /dev/null; then
  wget -q "https://github.com/prometheus/alertmanager/releases/download/v${ALERTMANAGER_VERSION}/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz"
  tar xf alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz
  sudo cp alertmanager-${ALERTMANAGER_VERSION}.linux-amd64/alertmanager /usr/local/bin/
  sudo chown alertmanager:alertmanager /usr/local/bin/alertmanager
else
  echo "Alertmanager already installed, skipping binary install..."
fi

# Always update alertmanager config with latest Slack webhook
sudo cp /tmp/observability/alertmanager.yml /etc/alertmanager/alertmanager.yml
sudo sed -i "s|SLACK_WEBHOOK_URL|${SLACK_WEBHOOK_URL}|g" /etc/alertmanager/alertmanager.yml
sudo chown -R alertmanager:alertmanager /etc/alertmanager /var/lib/alertmanager

if [ ! -f /etc/systemd/system/alertmanager.service ]; then
  sudo tee /etc/systemd/system/alertmanager.service > /dev/null <<EOF
[Unit]
Description=Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
Restart=always
RestartSec=5
ExecStart=/usr/local/bin/alertmanager \
  --config.file=/etc/alertmanager/alertmanager.yml \
  --storage.path=/var/lib/alertmanager \
  --web.listen-address=0.0.0.0:9093

[Install]
WantedBy=multi-user.target
EOF
else
  echo "Alertmanager service already exists, skipping..."
fi

# ── Install Blackbox Exporter ──────────────
echo "[7/9] Installing Blackbox Exporter..."
cd /tmp

if ! command -v blackbox_exporter &> /dev/null; then
  wget -q "https://github.com/prometheus/blackbox_exporter/releases/download/v${BLACKBOX_VERSION}/blackbox_exporter-${BLACKBOX_VERSION}.linux-amd64.tar.gz"
  tar xf blackbox_exporter-${BLACKBOX_VERSION}.linux-amd64.tar.gz
  sudo cp blackbox_exporter-${BLACKBOX_VERSION}.linux-amd64/blackbox_exporter /usr/local/bin/
  sudo chown blackbox:blackbox /usr/local/bin/blackbox_exporter
else
  echo "Blackbox Exporter already installed, skipping binary install..."
fi

if [ ! -f /etc/systemd/system/blackbox-exporter.service ]; then
  sudo tee /etc/systemd/system/blackbox-exporter.service > /dev/null <<EOF
[Unit]
Description=Blackbox Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=blackbox
Group=blackbox
Type=simple
Restart=always
RestartSec=5
ExecStart=/usr/local/bin/blackbox_exporter \
  --config.file=/etc/prometheus/blackbox.yml \
  --web.listen-address=0.0.0.0:9115

[Install]
WantedBy=multi-user.target
EOF
else
  echo "Blackbox Exporter service already exists, skipping..."
fi

# ── Install Loki ───────────────────────────
echo "[8/9] Installing Loki..."
cd /tmp

if ! command -v loki &> /dev/null; then
  wget -q "https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-linux-amd64.zip"
  sudo apt install -y unzip 2>/dev/null
  unzip -q -o loki-linux-amd64.zip
  sudo cp loki-linux-amd64 /usr/local/bin/loki
  sudo chown loki:loki /usr/local/bin/loki
else
  echo "Loki already installed, skipping binary install..."
fi

# Always update loki config
sudo cp /tmp/observability/loki-config.yml /etc/loki/loki-config.yml
sudo chown -R loki:loki /etc/loki /var/lib/loki

if [ ! -f /etc/systemd/system/loki.service ]; then
  sudo tee /etc/systemd/system/loki.service > /dev/null <<EOF
[Unit]
Description=Loki Log Aggregation
Wants=network-online.target
After=network-online.target

[Service]
User=loki
Group=loki
Type=simple
Restart=always
RestartSec=5
ExecStart=/usr/local/bin/loki \
  --config.file=/etc/loki/loki-config.yml

[Install]
WantedBy=multi-user.target
EOF
else
  echo "Loki service already exists, skipping..."
fi

# ── Install Tempo ──────────────────────────
echo "[9/9] Installing Tempo..."
cd /tmp

if ! command -v tempo &> /dev/null; then
  wget -q "https://github.com/grafana/tempo/releases/download/v${TEMPO_VERSION}/tempo_${TEMPO_VERSION}_linux_amd64.tar.gz"
  tar xf tempo_${TEMPO_VERSION}_linux_amd64.tar.gz
  sudo cp tempo /usr/local/bin/tempo
  sudo chown tempo:tempo /usr/local/bin/tempo
else
  echo "Tempo already installed, skipping binary install..."
fi

# Always update tempo config
sudo cp /tmp/observability/tempo-config.yml /etc/tempo/tempo-config.yml
sudo chown -R tempo:tempo /etc/tempo /var/lib/tempo

if [ ! -f /etc/systemd/system/tempo.service ]; then
  sudo tee /etc/systemd/system/tempo.service > /dev/null <<EOF
[Unit]
Description=Tempo Distributed Tracing
Wants=network-online.target
After=network-online.target

[Service]
User=tempo
Group=tempo
Type=simple
Restart=always
RestartSec=5
ExecStart=/usr/local/bin/tempo \
  --config.file=/etc/tempo/tempo-config.yml

[Install]
WantedBy=multi-user.target
EOF
else
  echo "Tempo service already exists, skipping..."
fi

# ── Install Grafana ────────────────────────
echo "[10/10] Installing Grafana..."

if ! dpkg -l grafana &> /dev/null; then
  sudo apt install -y apt-transport-https software-properties-common wget 2>/dev/null
  wget -q -O - https://apt.grafana.com/gpg.key | sudo apt-key add -
  echo "deb https://apt.grafana.com stable main" | \
    sudo tee /etc/apt/sources.list.d/grafana.list
  sudo apt update -y 2>/dev/null
  sudo apt install -y grafana=10.4.3 2>/dev/null
  sudo apt-mark hold grafana
else
  echo "Grafana already installed, skipping..."
fi

# Always update Grafana credentials
sudo sed -i "s/;admin_user = admin/admin_user = ${GRAFANA_ADMIN_USER}/" /etc/grafana/grafana.ini
sudo sed -i "s/admin_user = admin/admin_user = ${GRAFANA_ADMIN_USER}/" /etc/grafana/grafana.ini
sudo sed -i "s/;admin_password = admin/admin_password = ${GRAFANA_ADMIN_PASSWORD}/" /etc/grafana/grafana.ini
sudo sed -i "s/admin_password = admin/admin_password = ${GRAFANA_ADMIN_PASSWORD}/" /etc/grafana/grafana.ini

# Always update http settings
sudo sed -i "s/;http_port = 3000/http_port = 3000/" /etc/grafana/grafana.ini
sudo sed -i "s/;http_addr =/http_addr = 0.0.0.0/" /etc/grafana/grafana.ini

# Always update provisioning files
sudo cp -r /tmp/observability/grafana/provisioning/datasources/* \
  /etc/grafana/provisioning/datasources/
sudo cp -r /tmp/observability/grafana/provisioning/dashboards/* \
  /etc/grafana/provisioning/dashboards/

# Always update dashboard JSON files
sudo mkdir -p /var/lib/grafana/dashboards
sudo cp /tmp/observability/grafana/dashboards/*.json /var/lib/grafana/dashboards/
sudo chown -R grafana:grafana /etc/grafana /var/lib/grafana

# ── Reload systemd and start all services ──
echo "Starting all services..."
sudo systemctl daemon-reload

for service in prometheus node-exporter alertmanager blackbox-exporter loki tempo grafana-server pushgateway; do
  sudo systemctl enable $service
  sudo systemctl restart $service
  status=$(sudo systemctl is-active $service)
  echo "  $service: $status"
done

echo ""
echo "========================================="
echo "  Stack deployed successfully!"
echo "  Grafana:      http://${SERVER_IP}:3000"
echo "  Prometheus:   http://${SERVER_IP}:9090"
echo "  Alertmanager: http://${SERVER_IP}:9093"
echo "  Loki:         http://${SERVER_IP}:3100"
echo "  Tempo:        http://${SERVER_IP}:3200"
echo "  Pushgateway:  http://${SERVER_IP}:9091"
echo "========================================="