# Playbook: AWS EKS Cluster Setup and Real-Cost Teardown Verification

## WHY

EKS carries a fundamentally different cost and risk profile than most resources covered elsewhere in this framework — a control plane fee billed continuously while it exists, worker nodes on top of that, and no free tier. eksctl also creates multiple AWS resource types simultaneously (VPC, IAM roles, CloudFormation stack, the cluster itself), meaning a failed or incomplete attempt can leave several different kinds of orphaned resources behind, not just one. This genuinely warrants more rigorous safety discipline than a simpler single-resource provisioning task.

## WHAT This Playbook Delivers

A working EKS cluster provisioned safely within an explicit cost boundary, honest documentation of any real failures encountered along the way including ones without a fully identified root cause, and — critically — a rigorous, multi-resource-type teardown verification proving nothing was left running, not merely assumed clean because the last attempt reported failure.

## Prerequisites

eksctl installed. Real, current EKS pricing confirmed (per the cloud cost optimization playbook's escalation-trap awareness) before starting. An explicit hard cost ceiling and session-bound completion rule established before touching anything, per the bounded demo provisioning playbook.

## Steps

1. Verify actual IAM permissions before assuming a policy is sufficient. eksctl requires far broader permissions than the EKS API alone — it creates a VPC, multiple IAM roles, and a CloudFormation stack in the same operation. A policy scoped only to eks:* actions (mistaking a service-role policy like AmazonEKSClusterPolicy for what a human or CLI caller needs) will fail partway through, not upfront — confirm the caller's actual permissions cover IAM role creation and CloudFormation, not only EKS-specific actions.

2. When a permission-related failure occurs, fix the specific denied action rather than broadening scope generally, and expect this may reveal a second, deeper permission gap once the first is resolved — this "peel one layer, find another" pattern is a common, expected part of getting a genuinely correctly-scoped policy right, not a sign something is fundamentally wrong.

3. Be aware that a CloudFormation stack created by eksctl may have termination protection enabled by default, which can cause a failed stack to become stuck in a ROLLBACK_FAILED state that ordinary deletion cannot resolve — this requires explicitly disabling termination protection on that specific stack before deletion will succeed.

4. When a resource creation step fails without a clear, identifiable error message after a genuine, non-trivial wait, document this honestly as an unresolved root cause rather than guessing at an explanation to make the log feel more complete — an honest "this failed and the specific cause was not identified" is more valuable and more trustworthy than a plausible-sounding but unverified guess.

5. After any attempt — successful, failed, or abandoned — verify teardown across every distinct resource type eksctl may have touched, not only the cluster itself: the EKS cluster, any CloudFormation stacks (including ones in a failed or rolled-back state, not only completed ones), the VPC (confirming only the original default VPC remains, not an orphaned dedicated one), EC2 instances (confirming no worker nodes remain), and IAM roles (searching specifically for role names matching the tool or cluster name used). Checking only one or two of these after a failed multi-attempt session risks missing a genuine orphaned resource from an earlier attempt.

6. When confirming actual cost impact, cross-check at least two independent sources rather than trusting one figure — Cost Explorer's same-day data can lag and show an artificially low or zero figure for genuinely real recent usage, while cost anomaly detection or the billing summary page may reflect a more current, accurate number. State explicitly which figure is being trusted and why, rather than presenting two disagreeing numbers without resolution.

## Guardrail Check

Never assume a service-role policy (one meant to be attached to a resource the service itself assumes) is sufficient for a human or CLI caller's own permissions — these are genuinely different purposes even when named similarly. Never delete a stuck CloudFormation stack without first checking for and addressing termination protection specifically. Never consider teardown complete after checking only the primary resource type (the cluster itself) when the provisioning tool is known to create multiple resource types — verify each type independently. Never present two disagreeing cost figures without explicitly stating which is trusted and the reasoning why.

## Reference Implementation

See github.com/SwitchhToDevOpsIn90/devops-journey, Session 34 — three real, distinct EKS provisioning attempts. Attempt one failed on eks:DescribeClusterVersions due to an incorrectly-scoped service-role policy being used for a CLI caller. Attempt two, after that fix, failed on a deeper iam:CreateRole permission gap. Attempt three succeeded through control plane and addon creation, then failed after approximately 35 minutes at the node group stage with no identifiable root cause, honestly documented as unresolved rather than guessed at. All five resource types (EKS clusters, CloudFormation stacks including failed states, VPCs, EC2 instances, IAM roles) were independently reverified clean after the session, with cost impact cross-checked between a same-day Cost Explorer reading showing $0.00 (attributed to genuine reporting lag) and a cost anomaly detection figure of $0.33, explicitly treated as the more trustworthy number given known Cost Explorer lag documented since Session 18.
