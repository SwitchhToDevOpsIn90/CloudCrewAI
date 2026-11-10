#!/usr/bin/env bash
# Tests the policy hook with sample tool calls. Usage: bash hooks/test_policy.sh
cd "$(dirname "$0")/.." || exit 1
H=hooks/crew_policy.py
export CREW_APPROVALS=$(mktemp)
pass=0; fail=0
t() { # name expected_exit json
  echo "$3" | python3 $H >/dev/null 2>&1; got=$?
  if [ "$got" = "$2" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: $1 (expected $2 got $got)"; fi
}
b() { python3 -c 'import json,sys;print(json.dumps({"tool_name":"Bash","tool_input":{"command":sys.argv[1]}}))' "$1"; }
w() { python3 -c 'import json,sys;print(json.dumps({"tool_name":"Write","tool_input":{"content":sys.argv[1]}}))' "$1"; }
# should block (2)
t eksctl-delete 2 "$(b 'eksctl delete cluster --name demo')"
t terraform-destroy 2 "$(b 'terraform destroy -auto-approve')"
t kubectl-delete-pvc 2 "$(b 'kubectl delete pvc data-postgres-0')"
t delete-volume 2 "$(b 'aws ec2 delete-volume --volume-id vol-0abc')"
t s3-rm 2 "$(b 'aws s3 rm s3://bucket --recursive')"
t iam-delete-user 2 "$(b 'aws iam delete-user --user-name bob')"
t helm-uninstall 2 "$(b 'helm uninstall myapp')"
t force-push 2 "$(b 'git push --force origin main')"
t rm-rf 2 "$(b 'rm -rf ./data')"
t world-open 2 "$(b 'aws ec2 authorize-security-group-ingress --group-id sg-1 --protocol tcp --port 22 --cidr 0.0.0.0/0')"
t helm-prod 2 "$(b 'helm upgrade myapp ./chart -n production')"
t akia-in-file 2 "$(w 'key=AKI''AABCDEFGHIJKLMNOP')"
t arn-account 2 "$(w 'arn:aws:iam::1234''56789012:user/x')"
t docker-sock 2 "$(b 'docker run -d -v /var/run/docker.sock:/var/run/docker.sock jenkins/jenkins:2.580.2-lts-jdk21')"
t docker-privileged 2 "$(b 'docker run -d --privileged docker:dind')"
t port-8080-open 2 "$(b 'docker run -d -p 8080:8080 jenkins/jenkins:2.580.2-lts-jdk21')"
t port-8080-loopback 0 "$(b 'docker run -d -p 127.0.0.1:8080:8080 jenkins/jenkins:2.580.2-lts-jdk21')"
# should allow (0)
t get-pods 0 "$(b 'kubectl get pods -A')"
t helm-list 0 "$(b 'helm list')"
t aws-describe 0 "$(b 'aws ec2 describe-volumes --region us-east-1')"
t git-push 0 "$(b 'git push -u origin feature')"
t masked-arn 0 "$(w 'arn:aws:iam::<ACCOUNT_ID>:user/x')"
t plain-write 0 "$(w 'hello world')"
t not-json 0 "not json"
# approval: exact command allowed, a variant is still blocked
echo 'eksctl delete cluster --name demo' > "$CREW_APPROVALS"
t approved-exact 0 "$(b 'eksctl delete cluster --name demo')"
t approved-variant 2 "$(b 'eksctl delete cluster --name prod')"
export CREW_OWNED=$(mktemp); echo crew-demo > "$CREW_OWNED"
t owned-ns-allowed 0 "$(b 'kubectl delete namespace crew-demo --context minikube')"
t other-ns-blocked 2 "$(b 'kubectl delete namespace default')"
t owned-ns-plus-extra 2 "$(b 'kubectl delete namespace crew-demo kube-system')"
t owned-ns-context-first 0 "$(b 'kubectl --context minikube delete namespace crew-demo')"
t heredoc-data-allowed 0 "$(b $'cat > notes.md <<\'EOF\'\nkubectl delete namespace foo\neksctl delete cluster x\nEOF')"
t heredoc-into-bash-blocked 2 "$(b $'bash <<\'EOF\'\neksctl delete cluster x\nEOF')"
t real-delete-after-heredoc 2 "$(b $'cat > a.md <<\'EOF\'\ntext\nEOF\neksctl delete cluster x')"
rm -f "$CREW_APPROVALS" "$CREW_OWNED"
echo "passed=$pass failed=$fail"; [ "$fail" = 0 ]
