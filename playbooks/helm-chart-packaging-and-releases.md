# Playbook: Helm Chart Packaging, Releases, and Safe Upgrades

## WHY

An application on Kubernetes is several YAML files (Deployment, Service, and usually more) that must stay in step. Running it in dev, test and prod means several near-identical copies with small differences that are easy to get wrong. Helm packages those files into one versioned unit (a chart), lets per-environment differences live in a values file, and records every install and upgrade as a numbered revision that can be rolled back. The most important thing to understand is what Helm's "deployed" status does and does not mean: it means Kubernetes accepted the YAML, not that the pods are healthy.

## WHAT This Playbook Delivers

An application installed, upgraded, rolled back and uninstalled as a Helm release, with image and settings overridden through a values file instead of edited templates. A tested safe-upgrade pattern: `--wait` with automatic rollback, so a failed release reverts itself instead of being left marked deployed. A packaged chart file, kept out of version control.

## Prerequisites

Helm installed, and its version checked before copying any command (see step 1). A cluster to install into; a local Minikube cluster is enough and costs nothing. For a local cluster that cannot pull images from a remote registry, the application image must be built locally and loaded into the cluster. The vocabulary: chart (the package), values.yaml (the settings you may change), release (one installed copy), revision (each install or upgrade), repository (where charts are shared).

## Steps

1. Check the Helm version first: `helm version --short`. Flag names changed between major versions. Helm 4 renamed `--atomic` to `--rollback-on-failure`. Tutorials written for Helm 3 will use the old name, so confirm the flag with `helm upgrade --help` rather than copying it.

2. Scaffold a chart with `helm create <name>`. This produces a working starter chart, not a finished one: the default image is nginx, the app version in Chart.yaml is a leftover placeholder, and it ships optional templates (ingress, HPA, HTTPRoute) that are disabled by default. Treat it as a skeleton. A real chart sets its own app version, and any resource not in the templates (for example a ConfigMap) is not packaged until you write that template.

3. Override settings with your own values file instead of editing the chart's defaults. A small `my-values.yaml` setting the image repository, tag, pull policy and service port is enough. Pass it with `-f my-values.yaml`. Single values can be overridden on the command line with `--set`, which takes precedence over the file.

4. For a local cluster without registry access, build the image on the host and load it into the cluster (`docker build ...` then `minikube image load <image>:<tag>`), and set `pullPolicy: Never` in the values file. Confirm the image is present with `minikube image ls`. On a cluster that can reach a registry, use a normal pull policy and a pushed image.

5. Check before installing. Run `helm lint ./chart -f my-values.yaml`, then `helm template <release> ./chart -f my-values.yaml` and confirm the rendered output shows the image, ports and kinds you expect. This catches wrong values before any cluster state changes.

6. Install with `helm install <release> ./chart -f my-values.yaml`, wait with `kubectl rollout status deployment/<name> --timeout=120s`, and verify the real application responds (for example `kubectl port-forward` then `curl`). A successful install message alone is not proof.

7. Upgrade with `helm upgrade <release> ./chart -f my-values.yaml --set key=value`, then check `helm history <release>` and the pods. Each upgrade creates a new revision.

8. Know the failure mode before relying on a plain upgrade. Upgrading to an image tag that does not exist produced a revision reported as `deployed` with "Upgrade complete", while the new pod sat in an image error. The application kept answering only because the rolling update left the old pods running. Always verify pod health after an upgrade, never the Helm status alone.

9. Roll back by hand with `helm rollback <release> <revision>`. A rollback creates a new revision rather than returning to the old number (rolling back to revision 2 created revision 4 with the description "Rollback to 2"). Read history with that in mind.

10. For pipelines and unattended deploys, use automatic rollback: `helm upgrade ... --wait --timeout 60s --rollback-on-failure` (Helm 4; `--atomic` in Helm 3). In the tested run, the bad upgrade was marked failed (revision 5), and Helm automatically rolled back to the previous good settings as revision 6, with no downtime and no human action. Set a timeout that matches how long a healthy pod needs to become ready.

11. Package the chart with `helm package ./chart`, which produces a `<chart>-<version>.tgz`, and inspect it with `helm show chart <file>.tgz`. This is the shareable artifact you would upload to a chart repository. Because it can be rebuilt from the chart folder at any time, add `*.tgz` to `.gitignore` before committing.

12. Uninstall with `helm uninstall <release>` and verify that no resources remain with the release label (`kubectl get deploy,svc,pods -l app.kubernetes.io/instance=<release>`; pods may briefly show Terminating). By default, uninstall also deletes the release history, so `helm history` returns "release: not found". Use `--keep-history` if the release may need to be inspected or rolled back after uninstall.

13. Scan before committing, as in every session: `grep -rniE "password|secret|token"` and a 12-digit account-ID scan over the chart folder. The scaffolded chart contains template references such as `imagePullSecrets` and `secretName`; confirm any match is a template reference, never a value. Never put real secrets into values files that are committed.

14. Change the package, not just the values. Add optional features behind one switch and wrap every related template in the same `if`, so turning the feature off leaves nothing pointing at a missing resource (for example, `config.enabled` wraps both the ConfigMap template and the container's `envFrom`). Use `quote` on ConfigMap values so numbers and true/false stay as text, `toYaml | nindent N` to paste value blocks, and `{{-` to trim whitespace. Prove each conditional with `helm template` (the object appears or disappears) before installing.

15. Make config changes roll out. Environment variables are read once when a container starts, and a ConfigMap change does not alter the pod template, so pods are not replaced and keep the old value. Add `checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}` to the pod template annotations. Verify the failure and the fix with `kubectl exec ... env` after an upgrade; do not trust the ConfigMap alone.

16. Use one chart with a values file per environment (`values-dev.yaml`, `values-prod.yaml`) and `helm upgrade --install <release> ./chart -n <ns> --create-namespace -f values-<env>.yaml`, which works for both first install and upgrade so pipelines run the same command every time. Production values should set resource requests and limits. Bump the chart `version` whenever templates change; `appVersion` is the application's own version.

17. Know when Helm is the wrong tool. Kustomize (a base plus overlays, rendered with `kubectl kustomize`) patches plain YAML but has no releases, history or rollback; Helm has all three. Choose per need, and do not mix them without a reason.

18. Define reusable names once and validate inputs before install. Put a `define` block in `_helpers.tpl` (for example `dockerapp.configName`) and `include` it everywhere the name is needed, so it cannot drift between files. Use `default` for optional values (an empty image tag falls back to `.Chart.AppVersion`) and `required "message" .Values.x` for mandatory ones, which stops the render with your own message and the file and line. Add a `values.schema.json` to check types and limits (a wrong type or a replica count below 1 fails `helm lint` and install). Remember `required` checks that a value is present, not its type; the schema checks the type.

19. Inspect before and after installing: `helm get values <release>` (what you supplied), `helm get manifest <release>` (the YAML actually installed) and `helm template ... --debug` (shows where a render fails). Value precedence is chart defaults, then `-f` files, then `--set`; the later one wins. Not yet run: `helm test` (blocked on a local image pull), hooks and subcharts.

## Guardrail Check

Never treat a Helm `deployed` status as proof the application is healthy; verify pods and a real response. Never run production upgrades without `--wait` and automatic rollback. Never copy a Helm flag from a tutorial without checking it against the installed major version. Never rely on `helm rollback` returning to the old revision number; it creates a new one. Never uninstall a release you may need to roll back without `--keep-history`. Never commit the packaged `.tgz` or real secret values. Production upgrades and uninstalls of releases serving real traffic fall under the Production section of guardrails/never-do-without-approval.md (exact command and target, then approval); uninstalling also falls under irreversible deletion.

## Reference Implementation

See github.com/SwitchhToDevOpsIn90/devops-journey, Session 37 (feature commit 234b59b, merged in pull request #13 as fe5bcf7; session log merged as f38c79c). Helm v4.3.1 on Minikube, entirely free. A chart for the DockerApp Flask image (built from the Session 24 app and loaded into Minikube because the cluster could not reach registry.k8s.io), overridden with a small values file (image dockerapp:1.0, pullPolicy Never, port 5000). Lint and template checks passed before install; release myapp (revision 1) answered through port-forward; an upgrade to 2 replicas created revision 2; a deliberate upgrade to a non-existent image tag was reported as deployed (revision 3) while the new pod failed with ErrImageNeverPull and the app kept answering; a manual rollback produced revision 4; the same bad upgrade with `--wait --timeout 60s --rollback-on-failure` produced a failed revision 5 and an automatic rollback as revision 6; the chart was packaged as a 5 KB tgz kept out of Git; and uninstall removed all resources and the history.

Steps 14 to 17 come from Session 38 (devops-journey, feature branch merged in pull request #16 as 43bae04), also Helm on Minikube at no cost. A custom ConfigMap template with `if`, `range` and `quote`, wired in with `envFrom` under the same `if`; `helm template` proved the autoscaling conditional (replicas removed, HorizontalPodAutoscaler added); an upgrade changing only the ConfigMap left the pod with the old value until a checksum annotation was added, after which the next upgrade rolled out a new pod; one chart deployed to dev (1 pod, APP_ENV=dev) and prod (2 pods, requests and limits) with values files; chart bumped to 0.2.0; a Kustomize base plus prod overlay rendered with `kubectl kustomize` for comparison. All resources and namespaces were removed afterwards.

Steps 18 and 19 come from the Session 38 add-on (devops-journey pull request #17, merged as a35ec12): a named template used in two files, `default` turning an empty tag into the chart appVersion, `required` stopping a render with a clear error, a schema rejecting a text replica count and zero, and `helm get values`/`get manifest`/`--debug`. The `default` and `required` outputs were seen directly; the rest is from the session log.
