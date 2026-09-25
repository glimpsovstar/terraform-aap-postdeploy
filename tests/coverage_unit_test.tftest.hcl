# Coverage for paths the main unit tests do not reach.

mock_provider "aap" {
  mock_data "aap_workflow_job_template" {
    defaults = {
      id = 24
    }
  }
}

variables {
  inventory_name    = "Better Together Demo - ws-TEST"
  host_name         = "rhel9-vm"
  host_ansible_host = "10.0.0.10"
}

run "wait_for_completion_can_be_disabled" {
  command = plan

  variables {
    wait_for_completion = false
  }

  assert {
    condition     = var.wait_for_completion == false
    error_message = "Callers must be able to fire and forget."
  }
}

run "workflow_template_name_is_configurable" {
  command = plan

  variables {
    workflow_job_template_name = "Some Other Workflow"
  }

  assert {
    condition     = data.aap_workflow_job_template.post_deploy.name == "Some Other Workflow"
    error_message = "The workflow looked up must be the one requested."
  }
}

run "organization_is_configurable" {
  command = plan

  variables {
    organization_name = "Platform"
  }

  assert {
    condition     = data.aap_workflow_job_template.post_deploy.organization_name == "Platform"
    error_message = "The workflow must be looked up in the requested organization."
  }
}

run "inventory_carries_name_and_description" {
  command = plan

  variables {
    inventory_description = "Hosts built by workspace ws-TEST"
  }

  assert {
    condition     = aap_inventory.this.name == "Better Together Demo - ws-TEST"
    error_message = "Inventory name must be passed through unchanged."
  }

  assert {
    condition     = aap_inventory.this.description == "Hosts built by workspace ws-TEST"
    error_message = "Inventory description must be passed through."
  }
}

run "trigger_input_tracks_the_host_address" {
  command = plan

  assert {
    condition     = terraform_data.post_deploy[0].input.ansible_host == "10.0.0.10"
    error_message = "The trigger must track the host address, so a rebuilt host re-runs post-deployment."
  }
}

run "retrigger_does_not_clobber_the_host_keys" {
  command = plan

  variables {
    retrigger = { chrony = "3" }
  }

  assert {
    condition     = terraform_data.post_deploy[0].input.host == "rhel9-vm"
    error_message = "retrigger must merge with, not replace, the host identity keys."
  }

  assert {
    condition     = terraform_data.post_deploy[0].input.chrony == "3"
    error_message = "retrigger values must be present alongside the host keys."
  }
}

run "post_deploy_enabled_output_reflects_the_setting" {
  command = plan

  variables {
    run_post_deploy = false
  }

  assert {
    condition     = output.post_deploy_enabled == false
    error_message = "The output must tell callers whether post-deployment is wired."
  }
}
