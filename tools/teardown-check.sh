#!/usr/bin/env bash
# Read-only sweep proving a cloud demo left nothing billing behind.
# Usage: tools/teardown-check.sh <region> <name-filter>
#   example: tools/teardown-check.sh eu-north-1 session36
# For each resource type it prints one of: NONE FOUND, FOUND (needs a human look),
# or UNVERIFIED (the check could not run, for example AccessDenied). AccessDenied proves
# access is gone, not that the resources are gone, so an UNVERIFIED result is never a pass.
# Exit code: 0 = all checks ran and found nothing, 1 = something was found, 2 = some checks unverified.
# Status: the AWS commands marked [proven] were used in real sessions (34-36).
# Commands marked [standard] are common checks not yet exercised in a session.
# First live run (2026-11-07) had no read permissions, which exposed that the old version said
# "empty output means none found" even when every check had failed; fixed here.
# It never modifies anything and masks 12-digit account IDs in its output. It does NOT check
# the console-only views; open EC2 > Volumes and Snapshots in the console as well.
set -u
REGION="${1:?region required}"; FILTER="${2:?name filter required}"
FOUND=0; UNVERIFIED=0
mask() { sed -E 's/[0-9]{12}/<ACCOUNT_ID>/g'; }
check() { # label, then the aws command
  local label="$1"; shift
  echo; echo "== $label"
  local out rc
  out="$("$@" 2>&1)"; rc=$?
  if [ $rc -ne 0 ]; then
    echo "UNVERIFIED: command failed ($(echo "$out" | head -1 | cut -c1-110 | mask))"
    UNVERIFIED=$((UNVERIFIED+1))
  elif [ -z "$(echo "$out" | tr -d '[:space:]')" ]; then
    echo "NONE FOUND"
  else
    echo "FOUND (needs a human look):"; echo "$out" | mask; FOUND=$((FOUND+1))
  fi
}
check "EKS clusters [proven]" aws eks list-clusters --region "$REGION" --query 'clusters' --output text
check "CloudFormation stacks matching '$FILTER' not deleted [proven]" aws cloudformation list-stacks --region "$REGION" \
  --query "StackSummaries[?contains(StackName,'$FILTER') && StackStatus!='DELETE_COMPLETE'].[StackName,StackStatus]" --output text
check "VPCs that are not the default [proven]" aws ec2 describe-vpcs --region "$REGION" \
  --query 'Vpcs[?IsDefault==`false`].[VpcId]' --output text
check "Running instances [proven]" aws ec2 describe-instances --region "$REGION" --filters Name=instance-state-name,Values=running \
  --query 'Reservations[].Instances[].[InstanceId,InstanceType]' --output text
check "Unattached EBS volumes [proven]" aws ec2 describe-volumes --region "$REGION" --filters Name=status,Values=available \
  --query 'Volumes[].[VolumeId,Size]' --output text
check "IAM roles matching '$FILTER' [proven]" aws iam list-roles --query "Roles[?contains(RoleName,'$FILTER')].RoleName" --output text
check "Snapshots owned by this account [standard]" aws ec2 describe-snapshots --region "$REGION" --owner-ids self \
  --query 'Snapshots[].[SnapshotId,VolumeSize,StartTime]' --output text
check "NAT gateways not deleted [standard]" aws ec2 describe-nat-gateways --region "$REGION" \
  --query "NatGateways[?State!='deleted'].[NatGatewayId,State]" --output text
check "Unassociated Elastic IPs [standard]" aws ec2 describe-addresses --region "$REGION" \
  --query 'Addresses[?AssociationId==null].[PublicIp,AllocationId]' --output text
check "Load balancers [standard]" aws elbv2 describe-load-balancers --region "$REGION" \
  --query 'LoadBalancers[].[LoadBalancerName,State.Code]' --output text
echo
if [ $UNVERIFIED -gt 0 ]; then
  echo "RESULT: NOT VERIFIED. $UNVERIFIED check(s) could not run. Do not claim the teardown is clean."
  echo "Verify in the console (EC2 Volumes, Snapshots, EKS, Billing) or with a read-only role approved by the operator."
  exit 2
elif [ $FOUND -gt 0 ]; then
  echo "RESULT: $FOUND heading(s) listed resources. Review each one."; exit 1
else
  echo "RESULT: all checks ran and found nothing. Still check the console Volumes and Snapshots pages."; exit 0
fi
