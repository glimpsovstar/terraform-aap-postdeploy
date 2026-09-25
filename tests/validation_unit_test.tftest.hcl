# Contract tests: reject inputs that violate the module's promises.

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

run "rejects_blank_inventory_name" {
  command = plan

  variables {
    inventory_name = "   "
  }

  expect_failures = [var.inventory_name]
}

run "rejects_timeout_below_floor" {
  command = plan

  variables {
    wait_timeout_seconds = 30
  }

  expect_failures = [var.wait_timeout_seconds]
}

run "rejects_timeout_above_ceiling" {
  command = plan

  variables {
    wait_timeout_seconds = 99999
  }

  expect_failures = [var.wait_timeout_seconds]
}
