# Playbook: Kubernetes Persistent Storage, StatefulSets, and Safe Stateful Teardown

## WHY

Stateful workloads are where Kubernetes mistakes become data loss. A pod is disposable by design, so anything written inside its own filesystem disappears the moment the pod is replaced. A mistake in the storage layers above it (claim, volume, reclaim policy) either destroys real data or leaves a real, billing cloud disk behind after the cluster is gone. This playbook proves each layer separately on a free local cluster first, then proves the whole chain on real cloud infrastructure, and finishes with a teardown order that cannot orphan a disk.

## WHAT This Playbook Delivers

A database running as a StatefulSet on a cloud block volume, with data proven to survive pod deletion. A clear model of the chain: the data lives in the PersistentVolume (PV), the PersistentVolumeClaim (PVC) keeps the PV alive, and pods come and go. A tested understanding of the reclaim policy (`Delete` vs `Retain`), and a teardown sequence that removes disks before the cluster and independently verifies that no volume or snapshot remains.

## Prerequisites

A local cluster (Minikube) for the concept tests, which cost nothing. For the cloud portion: a working EKS setup per eks-cluster-setup.md, an explicit cost ceiling per bounded-demo-provisioning.md, and a Free Tier eligible node type (t3.small). Disabling the NAT gateway in the cluster config (`vpc.nat.gateway: Disable`) avoids an hourly NAT charge for a short demo.

## Steps

1. Prove the problem first, on the local cluster. Write a file inside a running pod's own filesystem (for example under /tmp), delete the pod, and read the file from its replacement. It is gone. Watch for a false result: if two pasted command blocks join together and the delete never runs, "Old" and "New" show the same pod name. Always print both pod names and confirm they differ before trusting the result.

2. Create a PVC and observe dynamic provisioning: applying a PVC against a cluster with a default StorageClass creates a PV automatically. Confirm with `kubectl get pvc` and `kubectl get pv`. Mount the PVC into a Deployment at a path such as /data, write a file, delete the pod, and confirm the file survives in the replacement pod.

3. Test the boundary on purpose. Delete the whole Deployment but keep the PVC, recreate the Deployment, and confirm the file is still there across entirely different pods. Then delete the PVC itself under reclaim policy `Delete` and confirm the PV is removed and the data is gone after recreating everything. This is the rule to internalize: workloads are disposable, the claim is what protects the data.

4. Use a StatefulSet when each replica needs its own identity and its own disk. A StatefulSet with a headless Service (`clusterIP: None`) and `volumeClaimTemplates` creates one PVC per replica (`data-web-0`, `data-web-1`). Write a different file to each replica, delete `web-0`, and confirm it returns with the same name and its own file. Deleting the StatefulSet itself leaves the PVCs behind; they must be deleted explicitly.

5. Test `Retain` before relying on it. With a StorageClass whose `reclaimPolicy` is `Retain`, delete the bound PVC and run `kubectl get pv`. The PV stays with status `Released`: the volume and its contents still exist, but it is tied to the deleted claim, so a new PVC will not bind it automatically, and an administrator must recover or delete it by hand. On a cloud provider, a Released PV backed by a real disk is a real disk that is still billing. Predict the outcome before running the delete; the prediction habit catches misunderstandings.

6. Move to real cloud storage only after the concepts are proven locally. Create the cluster with the EBS CSI driver add-on and OIDC enabled (the driver needs an IAM role). Verify the driver actually exists before building on it: `eksctl get addons` and `aws eks describe-addon ... --query 'addon.[status,serviceAccountRoleArn]'`.

7. Define the StorageClass explicitly. Recent EKS versions (1.30+) ship no default StorageClass, so a PVC without `storageClassName` can sit Pending. Use provisioner `ebs.csi.aws.com`, `type: gp3`, and `volumeBindingMode: WaitForFirstConsumer` so the volume is created in the same availability zone as the pod that will use it. Set `storageClassName` explicitly on every claim.

8. Create credentials without writing them into any file: `kubectl create secret generic pg-secret --from-literal=POSTGRES_PASSWORD="$(openssl rand -hex 16)"`, referenced from manifests via `secretKeyRef`. Scan the manifests and session log before committing (`grep -rniE "password|secret|token"` should show only references, never values, and a `[0-9]{12}` scan should show no account IDs).

9. Run PostgreSQL as a StatefulSet with a `volumeClaimTemplates` entry on the gp3 class. Set `PGDATA` to a subfolder of the mount (for example `/var/lib/postgresql/data/pgdata`): a fresh EBS volume has a `lost+found` directory at its root, and PostgreSQL refuses to initialize into a non-empty directory. Wait with `kubectl rollout status statefulset/postgres --timeout=300s`.

10. Prove the chain end to end. Confirm the PVC is Bound, then confirm the real cloud disk exists and is `in-use` with `aws ec2 describe-volumes --filters Name=tag-key,Values=CSIVolumeName`. Insert rows, delete `postgres-0`, and confirm the same rows are returned from the replacement pod on the same volume.

11. Backups: a CronJob running `pg_dump` into a separate PVC is a valid backup pattern, and `kubectl create job backup-now --from=cronjob/postgres-backup` runs it on demand so it can be verified without waiting for the schedule. Report this accurately: a manual Job created from a CronJob proves the backup logic, not that the schedule fires. Also note that a backup stored in the same cluster is not disaster recovery; real backups go off-cluster.

12. Tear down in this order and never reverse it: delete workloads (CronJob, Job, StatefulSet, Services), delete the PVCs while the cluster and CSI driver are still running so the driver can remove the EBS volumes, confirm with `describe-volumes` that the volumes are gone, then delete the cluster (`eksctl delete cluster --wait`). Deleting the cluster first can leave detached volumes with no controller left to clean them up.

13. Verify teardown across every resource type, independently: no EKS clusters (`aws eks list-clusters`), no non-deleted CloudFormation stacks matching the cluster name, only the default VPC, no unexpected running instances, no unattached volumes (`Name=status,Values=available`), no leftover IAM roles matching the cluster name, and then the EC2 console Volumes and Snapshots pages in the working region. Check Snapshots explicitly; the CLI checks above do not cover them.

14. Revoke any temporary IAM permissions last, then use a denied call as a boundary test: `aws eks list-clusters` returning `AccessDeniedException` proves the access is gone. It does not prove the cluster is gone, which is why all resource checks must run before access is removed.

## Guardrail Check

Deleting a PVC under reclaim policy `Delete` permanently destroys the data behind it: treat deleting any PVC that holds real (non-demo) data as irreversible deletion requiring human approval per guardrails/never-do-without-approval.md. Never delete the cluster before the PVCs when EBS-backed volumes exist. Never treat a `Released` PV on a cloud provider as harmless: it is a billing disk until deleted by hand. Never claim a scheduled job works when only a manual run from it was tested. Never treat an `AccessDenied` as evidence a resource is gone. Never commit manifests or logs without the secret and account-ID scan. Never store a backup only inside the cluster it protects and call it disaster recovery.

## Reference Implementation

See github.com/SwitchhToDevOpsIn90/devops-journey, Session 36 (commits 25ef020 and 0ee773f, merged via pull request #12 as 42cc304). Concept tests on Minikube: ephemeral file lost on pod replacement; PVC-backed file survived pod replacement and Deployment deletion across different pods; deleting the PVC under `Delete` removed the PV and the data; a two-replica StatefulSet kept per-replica identity and files; a `Retain` StorageClass left the PV `Released` after claim deletion, removed by hand. Real EKS run: cluster session36-storage (eu-north-1, one t3.small node, NAT disabled, EBS CSI add-on), gp3 StorageClass with WaitForFirstConsumer, PostgreSQL 16 StatefulSet creating a real 1 GB gp3 EBS volume, rows surviving deletion of postgres-0, and a pg_dump backup (1,053 byte db.sql containing the test row) produced by a manual Job created from the CronJob; the 02:00 schedule itself never fired because the cluster was torn down first. Teardown removed PVCs before the cluster, then verified clusters, CloudFormation stacks, VPCs, instances, unattached volumes and IAM roles clean, and the console showed only the unrelated ServerWatch volume and no snapshots. After all temporary permissions were revoked, `aws eks list-clusters` returned AccessDeniedException as expected. The account's credit balance moved by about $0.29 across the session and the following days of normal use (Billing can lag by a day or two, so a few more cents may still appear).
