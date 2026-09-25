output "inventory_id" {
  description = "ID of the AAP inventory this module created."
  value       = aap_inventory.this.id
}

output "inventory_name" {
  description = "Name of the AAP inventory."
  value       = aap_inventory.this.name
}

output "host_id" {
  description = "ID of the registered AAP host."
  value       = aap_host.this.id
}

output "workflow_job_template_id" {
  description = "ID of the workflow job template fired after creation."
  value       = data.aap_workflow_job_template.post_deploy.id
}

output "post_deploy_enabled" {
  description = "Whether the post-deployment workflow is wired to fire."
  value       = var.run_post_deploy
}
