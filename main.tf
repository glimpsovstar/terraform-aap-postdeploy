# ---------------------------------------------------------------------------
# Registers a host with Ansible Automation Platform and runs a post-deployment
# workflow against it.
#
# The action and the resource whose lifecycle triggers it live together here by
# necessity: Terraform rejects `module.x.action_ref` with "Actions can only be
# referenced in the module they are declared in". So this module owns both what
# runs and when it runs.
# ---------------------------------------------------------------------------

data "aap_workflow_job_template" "post_deploy" {
  name              = var.workflow_job_template_name
  organization_name = var.organization_name
}

resource "aap_inventory" "this" {
  name         = var.inventory_name
  description  = var.inventory_description
  organization = 1
}

resource "aap_host" "this" {
  inventory_id = aap_inventory.this.id
  name         = var.host_name
  variables    = jsonencode(local.host_variables)
}

action "aap_workflow_job_launch" "post_deploy" {
  config {
    workflow_job_template_id            = data.aap_workflow_job_template.post_deploy.id
    inventory_id                        = aap_inventory.this.id
    wait_for_completion                 = var.wait_for_completion
    wait_for_completion_timeout_seconds = var.wait_timeout_seconds
    extra_vars                          = jsonencode(local.extra_vars)
  }
}

# The trigger. Changing anything in `input` re-fires the workflow, which is how
# `retrigger` lets a caller re-run post-deployment without rebuilding the host.
resource "terraform_data" "post_deploy" {
  count = var.run_post_deploy ? 1 : 0

  input = merge(
    {
      host         = var.host_name
      ansible_host = var.host_ansible_host
    },
    var.retrigger,
  )

  depends_on = [aap_host.this]

  lifecycle {
    action_trigger {
      events  = [after_create, after_update]
      actions = [action.aap_workflow_job_launch.post_deploy]
    }
  }
}
