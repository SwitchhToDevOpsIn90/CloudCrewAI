#!/usr/bin/env bash
# Tests tools/check-k8s-manifest.py on generated manifests. No cluster access.
cd "$(dirname "$0")/.." || exit 1
D=$(mktemp -d); pass=0; fail=0; C="python3 tools/check-k8s-manifest.py"
ok() { if [ "$1" = "$2" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: $3 (got $1, wanted $2)"; fi; }
DIG="sha256:$(printf 'a%.0s' $(seq 64))"
mk() { # extra container lines (indented 10), pod lines (indented 6)
cat > "$D/m.yaml" <<YML
apiVersion: apps/v1
kind: Deployment
metadata: { name: t }
spec:
  template:
    spec:
      securityContext: { runAsNonRoot: true, runAsUser: 10001 }
$2
      containers:
        - name: c
          image: ${IMG:-python:3.13-alpine@$DIG}
          readinessProbe: { httpGet: { path: /, port: 5000 } }
          resources: { requests: { cpu: 50m }, limits: { memory: 128Mi } }
          securityContext: { allowPrivilegeEscalation: false, capabilities: { drop: [ALL] } }
$1
YML
}
unset IMG; mk "" ""; $C "$D/m.yaml" >/dev/null; ok $? 0 "good manifest passes"
IMG="python:latest" mk "" ""; $C "$D/m.yaml" >/dev/null; ok $? 1 "latest flagged"
IMG="python" mk "" ""; $C "$D/m.yaml" >/dev/null; ok $? 1 "untagged flagged"
IMG="python:3.13" mk "" ""; $C "$D/m.yaml" >/dev/null; ok $? 0 "tag without digest is a warning only"
IMG="python:3.13" mk "" ""; $C "$D/m.yaml" | grep -q "WARN.*digest"; ok $? 0 "digest warning shown"
IMG="IMAGE_PLACEHOLDER" mk "" ""; $C "$D/m.yaml" >/dev/null; ok $? 0 "template placeholder is a warning"
unset IMG; mk "          env: [{ name: DB_PASSWORD, value: hunter2 }]" ""; $C "$D/m.yaml" >/dev/null; ok $? 1 "literal secret env flagged"
mk "          env: [{ name: DB_PASSWORD, valueFrom: { secretKeyRef: { name: s, key: k } } }]" ""; $C "$D/m.yaml" >/dev/null; ok $? 0 "secretKeyRef allowed"
mk "          securityContext: { privileged: true }" ""; $C "$D/m.yaml" | grep -q "FLAG.*privileged"; ok $? 0 "privileged flagged"
mk "" "      hostNetwork: true"; $C "$D/m.yaml" >/dev/null; ok $? 1 "hostNetwork flagged"
mk "" "      volumes: [{ name: v, hostPath: { path: /var/run/docker.sock } }]"; $C "$D/m.yaml" >/dev/null; ok $? 1 "hostPath flagged"
sed -i 's/runAsUser: 10001/runAsUser: 0/' "$D/m.yaml"; $C "$D/m.yaml" >/dev/null; ok $? 1 "root flagged"
mk "" ""; sed -i '/resources:/d' "$D/m.yaml"; $C "$D/m.yaml" | grep -q "WARN.*limits"; ok $? 0 "missing limits warned"
mk "" ""; sed -i '/readinessProbe/d' "$D/m.yaml"; $C "$D/m.yaml" | grep -q "WARN.*readinessProbe"; ok $? 0 "missing readiness probe warned"
printf 'apiVersion: v1\nkind: Service\nmetadata: { name: s }\nspec: { type: LoadBalancer }\n' > "$D/svc.yaml"; $C "$D/svc.yaml" | grep -q "WARN.*LoadBalancer"; ok $? 0 "public Service warned"
$C >/dev/null; ok $? 2 "no argument is a usage error"
printf 'a: [unclosed\n' > "$D/bad.yaml"; $C "$D/bad.yaml" >/dev/null; ok $? 1 "unparseable file is flagged"
echo "passed=$pass failed=$fail"; rm -rf "$D"; [ "$fail" = 0 ]
