# The intended pairing: build the instance, then register it with AAP and run
# post-deployment against it.
#
# Placement comes from the root, not the modules, which is what lets the same
# pair serve a long-lived workspace and a per-request self-service workspace.

terraform {
  required_version = ">= 1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    aap = {
      source  = "ansible/aap"
      version = ">= 1.5"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "aap" {
  host     = var.aap_host
  username = var.aap_username
  password = var.aap_password
}

variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "vpc_id" { type = string }
variable "subnet_id" { type = string }
variable "key_pair_name" { type = string }
variable "workspace_id" { type = string }
variable "vault_ssh_ca_public_key" { type = string }
variable "aap_host" { type = string }
variable "aap_username" { type = string }

variable "aap_password" {
  type      = string
  sensitive = true
}

module "instance" {
  source  = "app.terraform.io/djoo-hashicorp/rhel-instance/aws"
  version = "~> 1.0"

  instance_name = "ha-demo-001"
  environment   = "Dev"
  instance_size = "Small"
  application   = "better-together-demo"

  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id
  key_pair_name = var.key_pair_name

  vault_ssh_ca_public_key = var.vault_ssh_ca_public_key

  tags = {
    ProjectCode  = "HA-2026-091"
    BusinessUnit = "Border Systems"
  }
}

module "postdeploy" {
  source = "../../"

  # Workspace-scoped so parallel workspaces get their own inventory.
  inventory_name        = "Better Together Demo - ${var.workspace_id}"
  inventory_description = "Hosts built by workspace ${var.workspace_id}"

  host_name         = module.instance.hostname
  host_ansible_host = module.instance.public_ip

  workflow_job_template_name = "AAP Post Deployment"
  wait_for_completion        = true
}

output "public_ip" {
  value = module.instance.public_ip
}

output "inventory_id" {
  value = module.postdeploy.inventory_id
}
