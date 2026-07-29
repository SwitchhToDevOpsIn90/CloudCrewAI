# Playbook: Terraform Infrastructure Provisioning

## WHY

Manually clicking through the AWS console to create resources is slow, error-prone, and leaves no record of exactly what was built or why. Infrastructure as Code makes every resource reproducible, version-controlled, and reviewable before it touches real infrastructure.

## WHAT This Playbook Delivers

A complete Terraform configuration provisioning a client's cloud infrastructure from a single command, with state tracked, changes previewable before applying, and the entire setup reproducible for disaster recovery or a second environment.

## Prerequisites

Terraform installed. AWS credentials configured with permissions scoped to exactly the resources this client's infrastructure requires. A remote state backend (S3 bucket with versioning and a DynamoDB lock table) to prevent state corruption from concurrent runs.

## Steps

1. Set up the remote state backend first, before writing any resource definitions. State that only exists locally is a single point of failure.

2. Structure the configuration into logical files: provider and backend configuration, variables, the actual resources, and outputs. Never put everything in one giant file for anything beyond a trivial setup.

3. Write resource definitions matching exactly what the client needs, using variables for anything that will differ between environments (region, instance size, environment name).

4. Run a plan before every apply, without exception. The plan shows exactly what will change, be created, or be destroyed, before anything actually happens.

5. Review the plan output specifically for any destroy actions on resources that were not intentionally being replaced. An unexpected destroy in a plan is the single most common way Terraform causes real damage.

6. Apply only after the plan has been reviewed. Tag every resource with a client identifier and a management tag indicating it is Terraform-managed, so nobody accidentally hand-edits it later.

7. Commit the Terraform configuration to version control immediately, excluding the state file itself and any files containing credentials.

## Guardrail Check

A plan showing any destroy action on a resource not being intentionally replaced requires human confirmation before applying, regardless of autonomy mode — this is exactly the kind of irreversible action the guardrails exist for. Never apply a plan you have not fully reviewed line by line.

## Reference Implementation

See github.com/iam-veeramalla/terraform-zero-to-hero for foundational patterns. Client-specific implementations should follow this same file structure: providers, variables, main resources, outputs.
