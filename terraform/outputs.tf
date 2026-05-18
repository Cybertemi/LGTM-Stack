output "grafana_url" {
  value = "http://${var.server_ip}:3000"
}

output "prometheus_url" {
  value = "http://${var.server_ip}:9090"
}

output "alertmanager_url" {
  value = "http://${var.server_ip}:9093"
}

output "loki_url" {
  value = "http://${var.server_ip}:3100"
}

output "tempo_url" {
  value = "http://${var.server_ip}:3200"
}