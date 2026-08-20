# Playbook: Kubernetes Core Objects and Self-Healing

## WHY

A container running via a single, bare Kubernetes Pod behaves like a one-off `docker run` — if it crashes or is deleted, nothing brings it back. This is not how Kubernetes is meant to be used, and it directly contradicts the value proposition of adopting Kubernetes in the first place. The real orchestration value only appears once the correct higher-level objects (Deployment, Service, ConfigMap, Secret) are actually used, wrapping a Pod with the reconciliation behavior that makes Kubernetes genuinely different from manually running containers.

## WHAT This Playbook Delivers

A resilient, self-healing deployment with stable network access, externalized non-sensitive configuration, and appropriately (though not over-) trusted handling of sensitive configuration — using the actual objects Kubernetes expects, not a bare Pod.

## Prerequisites

A working container image already tested standalone (per the Docker containerization playbook). A running Kubernetes cluster, local (Minikube, Kind) or managed (EKS), with kubectl configured against it.

## Steps

1. Prove the problem before fixing it: deploy a bare Pod directly, then deliberately delete it and observe that nothing recreates it. A bare Pod has zero self-healing — confirming this concretely, rather than only reading about it, makes the value of the next steps genuinely understood rather than assumed.

2. Wrap the Pod template in a Deployment rather than deploying a bare Pod directly. A Deployment's controller continuously watches for the actual running Pod count to match the desired replica count, and creates a replacement automatically the moment one is missing — this is the real mechanism behind Kubernetes's self-healing reputation, not something a bare Pod provides on its own.

3. Prove self-healing genuinely works this time, using the same test as Step 1: delete a Pod managed by the Deployment, and observe a replacement appear automatically and immediately, without any manual intervention. Watching the old Pod's Terminating status alongside the new Pod's Running status confirms this concretely.

4. Create a Service to give the Pod set a stable network identity. Pod IP addresses change every time a Pod is recreated, which the Deployment in Step 2 will do routinely — anything needing to reach the application must use the Service, not a Pod's individual IP directly, to survive routine Pod replacement.

5. Externalize non-sensitive configuration into a ConfigMap, and verify it is genuinely being received by the running Pod (checking actual environment variables inside the container, not just confirming the ConfigMap object exists) rather than assuming the injection worked correctly.

6. Store sensitive configuration in a Kubernetes Secret rather than a ConfigMap or a hardcoded value, consistent with the discipline established in the secrets incident response playbook. Understand precisely what protection this actually provides before relying on it.

## The Critical Distinction: Secrets Are Obscured, Not Encrypted

A Kubernetes Secret's data is base64-encoded, not encrypted, by default. Anyone with sufficient kubectl access to the cluster can trivially decode the real value with a single command combining kubectl get and a base64 decode — this is genuinely different from true encryption, where decoding requires a specific key, not merely read access. Verify this understanding directly: attempt to decode a real Secret's value using only standard kubectl access, and confirm it is genuinely readable, rather than assuming "Secret" implies strong protection by name alone.

This finding was demonstrated using a local Minikube cluster's default access context, which is inherently permissive — this proves base64 is not encryption, but does not by itself demonstrate what a properly configured production cluster's RBAC restrictions would prevent. In a real production cluster, restricting which users and service accounts can run kubectl get secret against sensitive namespaces is the actual security boundary — the encoding itself provides none. For genuinely sensitive values, prefer a dedicated secrets manager or a tool that provides real encryption (such as Sealed Secrets or an external secrets operator integrating with a cloud provider's secrets manager) rather than relying on a bare Kubernetes Secret alone.

## Guardrail Check

Never assume a Kubernetes Secret provides encryption-grade protection without verifying what the specific cluster's RBAC configuration actually restricts — the object type's name does not guarantee the protection level. Never skip proving self-healing with an actual deliberate Pod deletion test — a Deployment's configuration can appear correct without this live verification, the same discipline already established for volume persistence and branch protection elsewhere in this framework.

## Reference Implementation

See github.com/SwitchhToDevOpsIn90/devops-journey, Session 31 — a bare Pod deployed and deliberately deleted, confirmed to not self-heal, proving the problem concretely before Session 32 introduced the fix. Session 31 also encountered the same arm64/amd64 architecture mismatch from Sessions 21 and 23, now recurring in a third context, and a stale-token issue distinct from Docker CLI token expiry: a Kubernetes Secret storing an ECR credential is a static snapshot copied into cluster storage at creation time, unlike a Docker CLI login which is manually refreshed — meaning the Secret does not know or react to the underlying token's expiry, and requires explicit deletion and recreation rather than a simple re-login.

See Session 32 for the actual fix: the same application converted to a real Deployment, with self-healing proven live by deleting a Pod and watching Kubernetes automatically create a replacement, a Service proven to provide stable access across Pod replacement, a ConfigMap verified injected via a real printenv check inside the running container, and a Secret's real value successfully decoded using only standard kubectl access — concretely proving the "obscured, not encrypted" distinction rather than merely asserting it.
