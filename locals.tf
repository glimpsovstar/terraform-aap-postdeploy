locals {
  # _hosts defaults to "all" so validation playbooks actually match the host
  # they were given. Without it 4-validation.yml matches nothing and passes
  # vacuously, which is how a broken application can report a green workflow.
  extra_vars = merge({ _hosts = "all" }, var.extra_vars)

  host_variables = merge(
    { ansible_host = var.host_ansible_host },
    var.host_variables,
  )
}
