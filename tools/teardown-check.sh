#!/usr/bin/env bash
# Read-only sweep proving a cloud demo left nothing billing behind.
# Usage: tools/teardown-check.sh <region> <name-filter>
#   example: tools/teardown-check.sh eu-north-1 session36
# Prints each resource type. Anything listed under a heading needs a human look.
# Status: the AWS commands marked [proven] were used in real sessions (34-36).
# Commands marked [standard] are common checks not yet exercised in a session.
# This wrapper has not yet been run end to end; run it once at the next teardown.
# It never modifies anything. It does NOT check the console-only views; open
# EC2 > Volumes and Snapshots in the console as well.
set -u
REGION="${1:?region required}"; FILTER="${2:?name filter required}"
section() { echo; echo "== $1"; }
section "EKS clusters [proven]"
aws eks list-clusters --region "$REGION" --output text
section "CloudFormation stacks matching '$FILTER' not deleted [proven]"
aws cloudformation list-stacks --region "$REGION" \
  --query "StackSummaries[?contains(StackName,'$FILTER') && StackStatus!='DELETE_COMPLETE'].[StackName,StackStatus]" --output table
section "VPCs (only the default VPC should remain) [proven]"
aws ec2 describe-vpcs --region "$REGION" --query 'Vpcs[].[VpcId,IsDefault]' --output table
section "Running instances [proven]"
aws ec2 describe-instances --region "$REGION" --filters Name=instance-state-name,Values=running \
  --query 'Reservations[].Instances[].[InstanceId,InstanceType]' --output table
section "Unattached EBS volumes [proven]"
aws ec2 describe-volumes --region "$REGION" --filters Name=status,Values=available \
  --query 'Volumes[].[VolumeId,Size]' --output table
section "IAM roles matching '$FILTER' [proven]"
aws iam list-roles --query "Roles[?contains(RoleName,'$FILTER')].RoleName" --output text
section "Snapshots owned by this account [standard]"
aws ec2 describe-snapshots --region "$REGION" --owner-ids self \
  --query 'Snapshots[].[SnapshotId,VolumeSize,StartTime]' --output table
section "NAT gateways not deleted [standard]"
aws ec2 describe-nat-gateways --region "$REGION" \
  --query "NatGateways[?State!='deleted'].[NatGatewayId,State]" --output table
section "Unassociated Elastic IPs [standard]"
aws ec2 describe-addresses --region "$REGION" \
  --query 'Addresses[?AssociationId==null].[PublicIp,AllocationId]' --output table
section "Load balancers [standard]"
aws elbv2 describe-load-balancers --region "$REGION" \
  --query 'LoadBalancers[].[LoadBalancerName,State.Code]' --output table
echo; echo "teardown-check: review every heading above; empty output means none found."
