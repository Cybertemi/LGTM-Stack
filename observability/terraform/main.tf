terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_security_group_rule" "grafana" {
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.security_group_id
}

resource "aws_security_group_rule" "prometheus" {
  type              = "ingress"
  from_port         = 9090
  to_port           = 9090
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.security_group_id
}

resource "aws_security_group_rule" "alertmanager" {
  type              = "ingress"
  from_port         = 9093
  to_port           = 9093
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.security_group_id
}

resource "aws_security_group_rule" "loki" {
  type              = "ingress"
  from_port         = 3100
  to_port           = 3100
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.security_group_id
}

resource "aws_security_group_rule" "tempo" {
  type              = "ingress"
  from_port         = 3200
  to_port           = 3200
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.security_group_id
}

resource "aws_security_group_rule" "node_exporter" {
  type              = "ingress"
  from_port         = 9100
  to_port           = 9100
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.security_group_id
}

resource "aws_security_group_rule" "blackbox_exporter" {
  type              = "ingress"
  from_port         = 9115
  to_port           = 9115
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.security_group_id
}

resource "aws_security_group_rule" "otel_grpc" {
  type              = "ingress"
  from_port         = 4317
  to_port           = 4317
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.security_group_id
}

resource "aws_security_group_rule" "otel_http" {
  type              = "ingress"
  from_port         = 4318
  to_port           = 4318
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.security_group_id
}
resource "aws_security_group_rule" "pushgateway" {
  type              = "ingress"
  from_port         = 9091
  to_port           = 9091
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.security_group_id
}