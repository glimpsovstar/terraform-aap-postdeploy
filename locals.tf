locals {
  host_variables = merge(
    { ansible_host = var.host_ansible_host },
    var.host_variables,
  )
}
