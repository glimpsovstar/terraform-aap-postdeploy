# terraform-aap-postdeploy

Registers a host with Ansible Automation Platform and runs a post-deployment workflow
against it.

Pairs with
[`terraform-aws-rhel-instance`](https://github.com/glimpsovstar/terraform-aws-rhel-instance),
which builds the host. Split this way so the compute module stays reusable for workloads
that never touch Ansible.

## Usage

```hcl
module "postdeploy" {
  source  = "app.terraform.io/djoo-hashicorp/postdeploy/aap"
  version = "~> 1.0"

  inventory_name    = "Better Together Demo - ${var.TFC_WORKSPACE_ID}"
  host_name         = module.instance.hostname
  host_ansible_host = module.instance.public_ip

  workflow_job_template_name = "AAP Post Deployment"
}
```

## Why the trigger lives in here

Terraform rejects an action referenced across a module boundary:

```
Error: Invalid reference to action outside this module
Actions can only be referenced in the module they are declared in.
```

So the `action` and the resource whose `lifecycle` fires it must be co-located. This module
therefore owns both *what* runs after deployment and *when* it runs — which is the right
boundary anyway: "register this host and run post-deployment against it" is one job.

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `inventory_name` | string | — | Include something workspace-unique so parallel workspaces don't collide |
| `host_name` | string | — | Host name in the inventory |
| `host_ansible_host` | string | — | Address Ansible connects to |
| `inventory_description` | string | `Managed by Terraform` | |
| `organization_name` | string | `Default` | AAP organization |
| `host_variables` | map(string) | `{}` | Merged with `ansible_host` |
| `workflow_job_template_name` | string | `AAP Post Deployment` | Workflow fired after creation |
| `run_post_deploy` | bool | `true` | False registers the host without running anything |
| `wait_for_completion` | bool | `true` | A failed post-deployment fails the apply |
| `wait_timeout_seconds` | number | `1800` | 60–7200 |
| `retrigger` | map(string) | `{}` | Change a value to re-run without rebuilding the host |

## Outputs

`inventory_id` · `inventory_name` · `host_id` · `workflow_job_template_id` ·
`post_deploy_enabled`

## Notes

**Name the inventory per workspace.** `"Better Together Demo - ${var.TFC_WORKSPACE_ID}"` is
the pattern in use: AAP hosts are scoped to their inventory, so workspace-scoped inventories
let many workspaces manage a host of the same name without collision.

**The workflow must accept an inventory at launch.** Set `ask_inventory_on_launch = true`
on the workflow job template with no fixed inventory, otherwise the inventory this module
creates is ignored.

**`wait_for_completion = true` is deliberate.** A post-deployment that fails should fail the
apply rather than leaving a half-configured host reported as success.

## Testing

| | Location | Mode | Count | Needs a controller |
|---|---|---|---|---|
| Unit | `tests/` | `plan` + `mock_provider` | 15 | no |
| Integration | `tests-integration/` | `apply` | 3 | **yes** |

```bash
terraform fmt -check -recursive
terraform init -backend=false && terraform validate
tflint --recursive

# Unit - what CI runs. No controller, nothing created.
terraform test

# Integration - creates a real inventory and host.
terraform test -test-directory=tests-integration -var=host_ansible_host=10.0.0.10
```

Integration tests run with `run_post_deploy = false` throughout. They exist to prove the
inventory and host are really created and that the named workflow template resolves on the
controller; firing a workflow at a host that does not exist would fail for reasons that say
nothing about this module.

## Publishing

This module uses **branch-based publishing** in HCP Terraform, not tags. A version is
published by nominating a commit on `main`, which lets HCP Terraform run the module's tests
before the version exists. Repository tags are kept for human reference but no longer drive
publication.

## Examples

- [`examples/basic`](examples/basic) — register a host and run post-deployment
- [`examples/complete`](examples/complete) — the intended pairing with the compute module
