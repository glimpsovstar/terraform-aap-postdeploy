# Unit tests. mock_provider means no AAP controller is needed and no jobs run.

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

run "registers_host_with_ansible_host" {
  command = plan

  assert {
    condition     = aap_host.this.name == "rhel9-vm"
    error_message = "Host must be registered under the supplied name."
  }

  assert {
    condition     = strcontains(aap_host.this.variables, "10.0.0.10")
    error_message = "ansible_host must be present in the host variables."
  }
}

run "extra_host_variables_are_merged" {
  command = plan

  variables {
    host_variables = { ansible_user = "aap" }
  }

  assert {
    condition     = strcontains(aap_host.this.variables, "ansible_user")
    error_message = "Caller host_variables must be merged, not dropped."
  }

  assert {
    condition     = strcontains(aap_host.this.variables, "ansible_host")
    error_message = "ansible_host must survive the merge."
  }
}

run "post_deploy_trigger_exists_by_default" {
  command = plan

  assert {
    condition     = length(terraform_data.post_deploy) == 1
    error_message = "Post-deployment should be wired by default."
  }
}

run "post_deploy_can_be_disabled" {
  command = plan

  variables {
    run_post_deploy = false
  }

  assert {
    condition     = length(terraform_data.post_deploy) == 0
    error_message = "run_post_deploy = false must leave no trigger, so nothing fires."
  }
}

run "retrigger_values_reach_the_trigger" {
  command = plan

  variables {
    retrigger = { chrony = "2" }
  }

  assert {
    condition     = terraform_data.post_deploy[0].input.chrony == "2"
    error_message = "retrigger values must land in the trigger input so changing them re-fires."
  }
}
