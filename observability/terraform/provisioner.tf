resource "null_resource" "install_observability_stack" {

  # If any of these variables change, re-run the provisioner
  triggers = {
    server_ip   = var.server_ip
    install_sh  = filemd5("${path.module}/templates/install.sh")
  }

  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.server_user
    private_key = file(var.ssh_private_key_path)
  }

  # Create the directory on the server first
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /tmp/observability/alerts",
      "sudo mkdir -p /tmp/observability/grafana/provisioning/datasources",
      "sudo mkdir -p /tmp/observability/grafana/provisioning/dashboards",
      "sudo mkdir -p /tmp/observability/grafana/dashboards",
      "sudo chown -R ${var.server_user}:${var.server_user} /tmp/observability"
    ]
  }

  # Upload all config files
  provisioner "file" {
    source      = "${path.module}/templates/install.sh"
    destination = "/tmp/observability/install.sh"
  }

  provisioner "file" {
    source      = "${path.module}/templates/prometheus.yml"
    destination = "/tmp/observability/prometheus.yml"
  }

  provisioner "file" {
    source      = "${path.module}/templates/alertmanager.yml"
    destination = "/tmp/observability/alertmanager.yml"
  }

  provisioner "file" {
    source      = "${path.module}/templates/loki-config.yml"
    destination = "/tmp/observability/loki-config.yml"
  }

  provisioner "file" {
    source      = "${path.module}/templates/tempo-config.yml"
    destination = "/tmp/observability/tempo-config.yml"
  }

  provisioner "file" {
    source      = "${path.module}/templates/blackbox.yml"
    destination = "/tmp/observability/blackbox.yml"
  }

  provisioner "file" {
    source      = "${path.module}/templates/otel-config.yml"
    destination = "/tmp/observability/otel-config.yml"
  }

  provisioner "file" {
    source      = "${path.module}/templates/alerts/infrastructure.yml"
    destination = "/tmp/observability/alerts/infrastructure.yml"
  }

  provisioner "file" {
    source      = "${path.module}/templates/alerts/slo.yml"
    destination = "/tmp/observability/alerts/slo.yml"
  }

  provisioner "file" {
    source      = "${path.module}/templates/alerts/dora.yml"
    destination = "/tmp/observability/alerts/dora.yml"
  }

  provisioner "file" {
    source      = "${path.module}/templates/grafana/provisioning/datasources/datasources.yml"
    destination = "/tmp/observability/grafana/provisioning/datasources/datasources.yml"
  }

  provisioner "file" {
    source      = "${path.module}/templates/grafana/provisioning/dashboards/dashboards.yml"
    destination = "/tmp/observability/grafana/provisioning/dashboards/dashboards.yml"
  }

provisioner "file" {
  source      = "${path.module}/templates/grafana/dashboards/dora-dashboard.json"
  destination = "/tmp/observability/grafana/dashboards/dora-dashboard.json"
}
provisioner "file" {
  source      = "${path.module}/templates/grafana/dashboards/node-exporter.json"
  destination = "/tmp/observability/grafana/dashboards/node-exporter.json"
}

provisioner "file" {
  source      = "${path.module}/templates/grafana/dashboards/slo-error-budget.json"
  destination = "/tmp/observability/grafana/dashboards/slo-error-budget.json"
}

provisioner "file" {
  source      = "${path.module}/templates/grafana/dashboards/unified.json"
  destination = "/tmp/observability/grafana/dashboards/unified.json"
}

provisioner "file" {
  source      = "${path.module}/templates/grafana/dashboards/blackbox-exporter.json"
  destination = "/tmp/observability/grafana/dashboards/blackbox-exporter.json"
}

provisioner "file" {
  source      = "${path.module}/templates/alerts/slo-burn-rate.yml"
  destination = "/tmp/observability/alerts/slo-burn-rate.yml"
}
  # Run the install script passing secrets as arguments
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/observability/install.sh",
      "sudo /tmp/observability/install.sh '${var.grafana_admin_user}' '${var.grafana_admin_password}' '${var.slack_webhook_url}' '${var.server_ip}'"
    ]
  }

  

  # Always run after security group rules are applied
  depends_on = [
    aws_security_group_rule.grafana,
    aws_security_group_rule.prometheus,
    aws_security_group_rule.alertmanager,
    aws_security_group_rule.loki,
    aws_security_group_rule.tempo,
    aws_security_group_rule.node_exporter,
    aws_security_group_rule.blackbox_exporter,
    aws_security_group_rule.otel_grpc,
    aws_security_group_rule.otel_http,
    aws_security_group_rule.pushgateway,
  ]
}