# Minimal usage: register an existing host and run post-deployment against it.

terraform {
  required_version = ">= 1.14"

  required_providers {
    aap = {
      source  = "ansible/aap"
      version = ">= 1.5"
    }
  }
}

provider "aap" {
  host     = var.aap_host
  username = var.aap_username
  password = var.aap_password
}

variable "aap_host" { type = string }
variable "aap_username" { type = string }

variable "aap_password" {
  type      = string
  sensitive = true
}

variable "host_ip" { type = string }

module "postdeploy" {
  source = "../../"

  inventory_name    = "example-basic"
  host_name         = "rhel9-vm"
  host_ansible_host = var.host_ip
}

output "inventory_id" {
  value = module.postdeploy.inventory_id
}
