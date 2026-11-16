#!/usr/bin/env python3
"""Check Kubernetes manifests (Deployment, StatefulSet, DaemonSet, Job, CronJob, Pod) for the
safety rules proven in sessions 31 to 44. Read-only; never talks to a cluster.
Usage: tools/check-k8s-manifest.py <file-or-folder> [...]      (needs PyYAML: pip install pyyaml)
  FLAG  container image has no tag, or uses :latest
  FLAG  privileged container, hostNetwork, hostPID, hostPath volume, or allowPrivilegeEscalation true
  FLAG  runs as root (runAsUser 0) or sets runAsNonRoot false
  FLAG  secret-looking value written directly in env (names like PASSWORD, SECRET, TOKEN, KEY) instead of secretKeyRef
  WARN  image not pinned by digest (@sha256:); image is a template placeholder (check the rendered manifest)
  WARN  no runAsNonRoot / runAsUser set at pod or container level
  WARN  no resource limits, or no requests
  WARN  no readinessProbe on a long-running container (Deployment, StatefulSet, DaemonSet)
  WARN  allowPrivilegeEscalation not set to false; capabilities not dropped
  WARN  Service of type LoadBalancer or NodePort (public exposure; confirm it is intended)
Exit: 0 no FLAG, 1 at least one FLAG, 2 usage error. Status: v0, tested on generated fixtures
(tools/test_check_k8s_manifest.sh); the Session 44 manifest passes with no flags.
"""
import os, re, sys
try:
    import yaml
except ImportError:
    print("PyYAML is required: pip install pyyaml"); sys.exit(2)

WORKLOADS = {"Deployment": ("spec", "template", "spec"), "StatefulSet": ("spec", "template", "spec"),
             "DaemonSet": ("spec", "template", "spec"), "Job": ("spec", "template", "spec"),
             "CronJob": ("spec", "jobTemplate", "spec", "template", "spec"), "Pod": ("spec",)}
LONG_RUNNING = {"Deployment", "StatefulSet", "DaemonSet"}
SECRETISH = re.compile(r"(PASSWORD|PASSWD|SECRET|TOKEN|API_?KEY|PRIVATE_?KEY|ACCESS_?KEY)", re.I)

def dig(d, path):
    for k in path:
        if not isinstance(d, dict): return None
        d = d.get(k)
    return d

def check_doc(doc, name):
    flags, warns = [], []
    kind = doc.get("kind")
    if kind == "Service" and dig(doc, ("spec", "type")) in ("LoadBalancer", "NodePort"):
        warns.append(f"{name}: Service type {doc['spec']['type']} exposes the workload; confirm it is intended")
    if kind not in WORKLOADS:
        return flags, warns
    pod = dig(doc, WORKLOADS[kind]) or {}
    label = f"{name} {kind}/{dig(doc, ('metadata','name'))}"
    psc = pod.get("securityContext") or {}
    for key in ("hostNetwork", "hostPID"):
        if pod.get(key): flags.append(f"{label}: {key} is true")
    for v in pod.get("volumes") or []:
        if "hostPath" in v: flags.append(f"{label}: hostPath volume '{v.get('name')}'")
    for c in (pod.get("containers") or []) + (pod.get("initContainers") or []):
        cn = f"{label} container '{c.get('name')}'"
        img = c.get("image", "")
        if re.fullmatch(r"[A-Z0-9_]*PLACEHOLDER[A-Z0-9_]*|\$\{[^}]+\}|\{\{.*\}\}", img):
            warns.append(f"{cn}: image is a template placeholder ('{img}'); check the rendered manifest too")
        elif "@sha256:" not in img:
            tag = img.rsplit(":", 1)[1] if ":" in img.split("/")[-1] else ""
            if not tag or tag == "latest": flags.append(f"{cn}: image '{img}' has no tag or uses latest")
            else: warns.append(f"{cn}: image '{img}' is not pinned by digest")
        sc = c.get("securityContext") or {}
        if sc.get("privileged"): flags.append(f"{cn}: privileged")
        if sc.get("allowPrivilegeEscalation") is True: flags.append(f"{cn}: allowPrivilegeEscalation true")
        elif sc.get("allowPrivilegeEscalation") is not False: warns.append(f"{cn}: allowPrivilegeEscalation not set to false")
        if "ALL" not in ((sc.get("capabilities") or {}).get("drop") or []): warns.append(f"{cn}: capabilities not dropped (drop: [ALL])")
        uid = sc.get("runAsUser", psc.get("runAsUser"))
        nonroot = sc.get("runAsNonRoot", psc.get("runAsNonRoot"))
        if uid == 0 or nonroot is False: flags.append(f"{cn}: runs as root")
        elif uid is None and nonroot is None: warns.append(f"{cn}: no runAsNonRoot or runAsUser set")
        res = c.get("resources") or {}
        if not (res.get("limits") or {}): warns.append(f"{cn}: no resource limits")
        if not (res.get("requests") or {}): warns.append(f"{cn}: no resource requests")
        if kind in LONG_RUNNING and not c.get("readinessProbe"): warns.append(f"{cn}: no readinessProbe")
        for e in c.get("env") or []:
            if SECRETISH.search(str(e.get("name", ""))) and "value" in e and "valueFrom" not in e:
                flags.append(f"{cn}: env {e['name']} holds a literal value; use secretKeyRef")
    return flags, warns

def main(argv):
    if not argv:
        print(__doc__); return 2
    files = []
    for a in argv:
        if os.path.isdir(a):
            for r, _, fs in os.walk(a):
                files += [os.path.join(r, f) for f in sorted(fs) if f.endswith((".yml", ".yaml"))]
        else: files.append(a)
    if not files:
        print("no manifest files found"); return 2
    nf = 0
    for f in files:
        try:
            docs = [d for d in yaml.safe_load_all(open(f)) if isinstance(d, dict)]
        except (OSError, yaml.YAMLError) as e:
            print(f"FLAG {f}: cannot parse ({str(e).splitlines()[0]})"); nf += 1; continue
        for d in docs:
            fl, wa = check_doc(d, f)
            for x in fl: print("FLAG", x)
            for x in wa: print("WARN", x)
            nf += len(fl)
    print(f"check-k8s-manifest: {len(files)} file(s), {nf} flag(s)")
    return 1 if nf else 0

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
