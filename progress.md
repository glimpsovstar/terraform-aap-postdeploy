# progress.md

## Goal / scope

AAP half of the Home Affairs demo module pair: register a host with Ansible Automation
Platform and run a post-deployment workflow against it.

## Done

- v1.0.0: inventory, host registration, workflow action, trigger resource.
- 8 tests passing on `mock_provider`; `terraform validate` and `tflint` clean.
- GitHub Actions running fmt / validate / tflint / test on PR.

## Next

- Publish to the `djoo-hashicorp` private module registry.
- Consume from the Demo 1 root alongside `terraform-aws-rhel-instance`.

## Key context

- **The action and its trigger must be co-located.** Terraform errors with "Actions can only
  be referenced in the module they are declared in", so this module owns
  `terraform_data.post_deploy` as well as the action. Verified, not assumed.
- **Requires Terraform >= 1.14** — actions are the constraint, not the aap provider.
- The target workflow needs `ask_inventory_on_launch = true` and no fixed inventory.
  Workflow 24 "AAP Post Deployment" already satisfies this.
- Inventory names must be workspace-scoped or parallel workspaces collide.
