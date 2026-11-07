# Playbook: Decommissioning Cloud Resources and Deleting Data Safely

## WHY

Deleting a long-lived client environment is different from tearing down your own demo. The data may be the only copy, the person asking may not have the authority to decide, and the cluster may still be referenced by something that looks unrelated. Deletion is irreversible, so everything that can be checked before it must be checked first, and the approval must name the exact resources.

## WHAT This Playbook Delivers

A safe sequence for removing a client's old environment: confirm authority and intent, inventory what exists, protect the data, get approval on a list of exact resources, delete in the correct order, and prove nothing is left, with evidence.

## Prerequisites

Read access to the account first, per environment-discovery.md. A human operator available for approval. The resource ledger template (templates/resource-ledger.md) for recording what is removed.

## Steps

1. Confirm authority and scope. A chat request such as "delete the old cluster, we don't need the data" is not enough by itself. Ask the human operator to confirm who is authorised to approve deletion for this client, and which environment is meant. Check the account, region and name so the target is not the live platform.

2. Inventory read-only. List the cluster, node groups, namespaces, persistent volume claims and volumes (and each volume's reclaim policy), snapshots, load balancers, DNS records, buckets, databases and CloudFormation or Terraform stacks tied to it. Note which tool created them, because teardown differs between eksctl, Terraform and manual builds.

3. Check what still depends on it. Look for DNS, ingress, other workloads, pipelines, monitoring and the new platform pointing at the old environment. A resource that looks unused may not be.

4. Protect the data before deleting. Decide with the operator whether a backup or final snapshot is required, whether a retention window applies (for example, scale to zero or stop first and wait a set period before deleting), and where backups live. A backup that was never restored is untested; record it as such.

5. Write a deletion manifest naming every resource by exact identifier, with size, tags and last-known use, and mark each as "demo / no real data" or "may hold client data". Send it to the human operator for approval. Pause only the delete steps; keep discovery and preparation going.

6. After approval, delete in order: workloads and scheduled jobs first, then persistent volume claims while the cluster and its storage driver are still running so the disks are removed, then confirm the volumes are gone, then the cluster or stack. Any volume with a Retain policy or a Released status must be handled and approved individually, because it is a real disk that keeps billing.

7. Verify with a full sweep, twice: tools/teardown-check.sh for the region and name, then the console pages the CLI does not cover (Volumes and Snapshots). Include load balancers, network interfaces, Elastic IPs, log groups, KMS keys, OIDC providers, registries and DNS records that the sweep may not list.

8. Record the result in the resource ledger with the evidence, revoke any temporary permissions last, and prepare a completion report in confirmed / inferred / unknown form for the operator to review before it goes to the client.

## Guardrail Check

Never delete anything that may hold client data without confirmation naming the exact resources. A client's request alone does not name resources or prove authority. Never delete the cluster before its persistent volume claims when the storage is cloud-backed. Never treat an AccessDenied after revoking access as proof the resources are gone. Never skip the backup decision, and never call a backup good if it was never restored.

## Reference Implementation

The deletion order, the Retain and Released handling and the two-pass verification come from the proven Session 36 teardown (devops-journey commits 25ef020, 0ee773f, merge 42cc304) and the Session 34 and 35 EKS teardowns. The authority check, inventory, dependency review, retention window and approval manifest are standard practice not yet exercised on a client environment. They were added after a blind routing test in which an agent correctly paused on a "delete the old cluster" request and asked for a decommission procedure.
