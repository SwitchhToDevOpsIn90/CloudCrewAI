# Playbook: Kubernetes Core Objects, Self-Healing, and Networking

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

## Exposing a Service Beyond the Cluster: Service Types and Ingress

A ClusterIP Service (the default, used above) is only reachable from inside the cluster — this is why testing it requires kubectl port-forward, a debugging tool rather than a real external access method. Real external access requires a different Service type or an Ingress resource.

7. For simple external access, change the Service type to NodePort, which opens the same port on every cluster node, reachable externally via that node's IP and the assigned port. Be aware this behaves differently depending on the cluster environment: on a real cloud-managed cluster or native Linux, the node IP is directly reachable. On a local Minikube cluster using the Docker driver on macOS specifically, the cluster runs inside a Docker container that macOS's networking stack cannot route to directly — a direct NodePort connection attempt will genuinely time out, not due to misconfiguration but a real platform limitation, and minikube service --url (a local tunnel) is required as a workaround in that specific environment only.

8. For genuine HTTP-aware routing (host-based or path-based routing to different backends through one entry point), use an Ingress resource, which requires an Ingress Controller (such as nginx-ingress) actually running in the cluster to function — an Ingress manifest alone, without a controller, does nothing.

9. Verify Ingress routing genuinely end-to-end, not just that the resources exist: confirm DNS or hosts-file resolution for the hostname routes to the correct address, confirm the tunnel or load balancer routing that address to the Ingress Controller, and confirm a real HTTP request receives the expected application response — tracing the complete real path rather than checking each piece in isolation.

10. When a local tunnel or proxy process appears to conflict with a new attempt to start one (a "tunnel already running" or similar port-conflict error), check for a genuine leftover process from an earlier session using a process list search for the relevant tool name, and terminate the specific stray process by its process ID before retrying — rather than assuming the current attempt is fundamentally broken.

11. After any disruption to the underlying container runtime hosting the cluster (a Docker Desktop restart, a Mac reboot), verify the cluster's actual state recovered correctly rather than assuming it did — confirming Pods are still Running and Services still resolve is a stronger, more realistic resilience proof than only testing recovery from a deliberate, controlled deletion.

## Guardrail Check

Never assume a Kubernetes Secret provides encryption-grade protection without verifying what the specific cluster's RBAC configuration actually restricts — the object type's name does not guarantee the protection level. Never skip proving self-healing with an actual deliberate Pod deletion test — a Deployment's configuration can appear correct without this live verification, the same discipline already established for volume persistence and branch protection elsewhere in this framework. Never assume a local development cluster's networking behavior (particularly Minikube on macOS) generalizes to a real cloud-managed cluster — verify platform-specific behavior explicitly rather than assuming portability. Never assume a process-conflict error means the current configuration is broken without first checking for a genuine leftover process from an earlier session.

## Reference Implementation

See github.com/SwitchhToDevOpsIn90/devops-journey, Session 31 — a bare Pod deployed and deliberately deleted, confirmed to not self-heal, proving the problem concretely before Session 32 introduced the fix. Session 31 also encountered the same arm64/amd64 architecture mismatch from Sessions 21 and 23, now recurring in a third context, and a stale-token issue distinct from Docker CLI token expiry: a Kubernetes Secret storing an ECR credential is a static snapshot copied into cluster storage at creation time, unlike a Docker CLI login which is manually refreshed — meaning the Secret does not know or react to the underlying token's expiry, and requires explicit deletion and recreation rather than a simple re-login.

See Session 32 for the actual fix: the same application converted to a real Deployment, with self-healing proven live by deleting a Pod and watching Kubernetes automatically create a replacement, a Service proven to provide stable access across Pod replacement, a ConfigMap verified injected via a real printenv check inside the running container, and a Secret's real value successfully decoded using only standard kubectl access — concretely proving the "obscured, not encrypted" distinction rather than merely asserting it.

See Session 33 for real external networking verification: a genuine Mac/Docker-driver-specific NodePort limitation encountered and confirmed (a direct connection attempt timing out due to macOS being unable to route to the Minikube container's internal IP, not misconfiguration), worked around correctly with a local tunnel rather than a real fix being needed. A real Ingress Controller was enabled and a real Ingress resource verified end-to-end: hosts-file DNS resolution, tunnel routing, and a genuine HTTP response all traced together, not checked in isolation. A real "tunnel already running" conflict was diagnosed to a specific leftover process by PID and terminated before retrying successfully. The cluster's state was also confirmed to have genuinely survived an unplanned Docker Desktop restart, a stronger resilience proof than the deliberate deletion tests alone.
