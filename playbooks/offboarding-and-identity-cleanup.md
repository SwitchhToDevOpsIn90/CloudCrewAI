# Playbook: Offboarding a Departed Engineer's Cloud Access and Resources

## WHY

When someone leaves, their IAM user, access keys and any buckets they created may still be live or in use by systems nobody remembers. Deleting too fast breaks pipelines or destroys the only copy of data; leaving keys active is a security exposure.

## WHAT This Playbook Delivers

A safe sequence: confirm authority, inventory the identity and what it created, contain access first, then delete exact approved resources and prove they are gone.

## Prerequisites

Read access per environment-discovery.md. A human operator for approvals. The resource ledger (templates/resource-ledger.md).

## Steps

1. Confirm authority and scope with the human operator: who may approve this for the client, which account and region, and whether the person's data must be kept. A client message alone does not prove authority or name resources.

2. Inventory the IAM user read-only: console login, MFA devices, access keys with last-used dates, groups, attached and inline policies, signing certificates, SSH keys.

3. Find what the user created. S3 records no creator, so use CloudTrail CreateBucket events, tags and naming, and label each attribution confirmed or inferred. Record versioning, Object Lock, replication, policies and object counts.

4. Check dependencies: roles that trust the user, pipelines or apps using its keys (last-used data), and code or Terraform that references the buckets.

5. Contain first, with approval: deactivate (do not delete) access keys and console login. Wait a defined period and watch for breakage. Record it in the ledger. If the keys are suspected exposed, follow secrets-incident-response.md instead.

6. Decide with the operator whether each bucket needs an export or backup and a retention window. Versioned buckets need every version and delete marker removed; Object Lock or legal holds can block deletion.

7. Write a deletion manifest of exact ARNs and bucket names, with size and last-known use, each marked "demo / no real data" or "may hold client data". Operator approves. Pause only the deletes.

8. After approval, delete in order: access keys, login profile, MFA, group memberships, policies, certificates, then the user. Empty and delete each approved bucket.

9. Verify twice with real reads: get-user and list-access-keys return NoSuchEntity, head-bucket returns 404 for each bucket. An AccessDenied is not proof of deletion.

10. Record evidence in the ledger, revoke temporary permissions last, and prepare a confirmed / inferred / unknown report for the operator to review before it reaches the client.

## Guardrail Check

Never delete an IAM user or bucket without approval naming the exact resource. Never delete before deactivating and watching for breakage. Never assume unused means unused. Never send the report to the client without operator review.

## Reference Implementation

Standard practice, not yet exercised on a real client account. Added after a blind test (S10) found no offboarding procedure. Deletion order and verification follow decommission-and-data-deletion.md.
