# Integration test. Creates a REAL inventory and host on a REAL AAP controller.
#
# Deliberately kept out of tests/ so CI does not run it. Run explicitly:
#
#   terraform test -test-directory=tests-integration \
#     -var=host_ansible_host=10.0.0.10
#
# with AAP_HOST / AAP_USERNAME / AAP_PASSWORD set for the provider.
#
# run_post_deploy is false throughout. The point is to prove the inventory and
# host are really created; firing a workflow at a host that does not exist
# would fail for reasons that say nothing about this module.

# A module must not configure its own provider, so the integration run
# configures it here. Credentials come from AAP_HOST / AAP_USERNAME /
# AAP_PASSWORD in the environment.
provider "aap" {}

variables {
  inventory_name        = "tftest-integration"
  inventory_description = "Created by terraform test, safe to delete"
  host_name             = "tftest-host"
  host_ansible_host     = "10.0.0.10"
  run_post_deploy       = false
}

run "inventory_and_host_are_really_created" {
  command = apply

  assert {
    condition     = aap_inventory.this.id != null
    error_message = "The inventory must actually be created on the controller."
  }

  assert {
    condition     = aap_host.this.id != null
    error_message = "The host must actually be registered."
  }

  assert {
    condition     = output.inventory_name == "tftest-integration"
    error_message = "The created inventory must carry the requested name."
  }
}

run "workflow_template_really_resolves" {
  command = apply

  assert {
    condition     = output.workflow_job_template_id != null
    error_message = "The named workflow job template must exist on the controller. If this fails, the template name is wrong or lives in another organization."
  }
}

run "host_variables_really_contain_the_address" {
  command = apply

  assert {
    condition     = strcontains(aap_host.this.variables, "10.0.0.10")
    error_message = "The registered host must carry ansible_host so Ansible can reach it."
  }
}
