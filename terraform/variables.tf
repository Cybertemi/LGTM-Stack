variable "aws_region" {
  description = "AWS region where the EC2 instance is hosted"
  type        = string
}

variable "security_group_id" {
  description = "Existing EC2 security group ID"
  type        = string
}

variable "instance_id" {
  description = "Existing EC2 instance ID"
  type        = string
}

variable "server_ip" {
  description = "Existing EC2 public IP address"
  type        = string
}

variable "server_user" {
  description = "SSH username for the EC2 instance"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key for EC2 access"
  type        = string
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for alert notifications"
  type        = string
  sensitive   = true
}

variable "grafana_admin_user" {
  description = "Grafana admin username"
  type        = string
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}