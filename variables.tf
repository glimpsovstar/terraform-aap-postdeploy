# ---------------------------------------------------------------------------
# Inventory
# ---------------------------------------------------------------------------

variable "inventory_name" {
  description = "Name of the AAP inventory to create. Include something workspace-unique so parallel workspaces do not collide."
  type        = string

  validation {
    condition     = length(trimspace(var.inventory_name)) > 0
    error_message = "Inventory name is required."
  }
}

variable "inventory_description" {
  description = "Description recorded on the inventory."
  type        = string
  default     = "Managed by Terraform"
}

variable "organization_name" {
  description = "AAP organization that owns the inventory and job templates."
  type        = string
  default     = "Default"
}

# ---------------------------------------------------------------------------
# Host
# ---------------------------------------------------------------------------

variable "host_name" {
  description = "Host name as it appears in the inventory."
  type        = string
}

variable "host_ansible_host" {
  description = "Address Ansible connects to - usually the instance's public or private IP."
  type        = string
}

variable "host_variables" {
  description = "Extra host variables merged with ansible_host."
  type        = map(string)
  default     = {}
}

# ---------------------------------------------------------------------------
# Post-deployment workflow
# ---------------------------------------------------------------------------

variable "workflow_job_template_name" {
  description = "Workflow job template fired against the host after creation."
  type        = string
  default     = "AAP Post Deployment"
}

variable "run_post_deploy" {
  description = "Fire the post-deployment workflow. Set false to register the host without running anything."
  type        = bool
  default     = true
}

variable "wait_for_completion" {
  description = "Block the Terraform apply until the workflow finishes. Keeping this true means a failed post-deployment fails the apply."
  type        = bool
  default     = true
}

variable "wait_timeout_seconds" {
  description = "How long to wait for the workflow before giving up."
  type        = number
  default     = 1800

  validation {
    condition     = var.wait_timeout_seconds >= 60 && var.wait_timeout_seconds <= 7200
    error_message = "Timeout must be between 60 and 7200 seconds."
  }
}

variable "retrigger" {
  description = "Arbitrary values that re-fire the workflow when changed. Use it to re-run post-deployment without rebuilding the host."
  type        = map(string)
  default     = {}
}
