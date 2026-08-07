# Playbook: Container Registry Setup and Cross-Machine Deployment

## WHY

A locally-built image only exists on the machine that built it. Getting it to run anywhere else — a teammate's machine, a staging server, production — requires a registry both machines can reach, set up with the same cost and security discipline as everything else in this framework.

## WHAT This Playbook Delivers

A private container registry (Amazon ECR by default, given AWS-based infrastructure), a working authenticate-tag-push-pull cycle, an automatic cleanup policy preventing storage costs from growing unbounded, and a deployment verified genuinely working on the target machine, not just assumed to work.

## Prerequisites

An image already built and tested locally, per the Docker containerization playbook. AWS CLI access with permission to create IAM resources and ECR repositories.

## Steps

1. Before provisioning anything, check current ECR pricing and confirm the expected usage fits within Free Tier or an acceptable cost threshold. Private ECR storage includes a free allowance for the first 12 months; same-region transfer to an EC2 instance is free; costs appear only beyond the storage allowance or for cross-region and internet-bound transfer.

2. Watch for account-level upgrade traps specifically. Some AWS features (IAM Identity Center is a known example) will force the entire account off a Free Tier or credits-based plan the moment they are enabled, regardless of whether the feature itself is free. Always check for this category of trap before enabling anything new, not just the specific feature's own price.

3. Create a dedicated, tightly-scoped IAM user or role for registry access, limited to the specific repository being used, not blanket ECR access across the account.

4. Create the ECR repository in the same region as the deployment target, so pulls remain free and fast.

5. Authenticate Docker to the registry, tag the local image for that specific registry destination, and push it.

6. Immediately set a lifecycle policy limiting how many image versions are retained — unbounded image accumulation is the most common real ECR cost mistake, and is trivial to prevent from the start but tedious to clean up after the fact.

7. Test the actual boundary of the least-privilege access just configured — confirm the scoped user genuinely cannot perform actions outside its intended scope, the same verification discipline applied everywhere else in this framework.

8. On the target machine, authenticate using an IAM Role rather than static credentials wherever the target is AWS infrastructure, consistent with the secrets incident response playbook's core principle.

9. Pull and run the image on the target machine, and verify it is genuinely serving requests there, not merely assumed to work because the push succeeded.

## A Real, Recurring Gotcha: CPU Architecture Mismatch

An image built on an Apple Silicon Mac defaults to the arm64 architecture. Most cloud servers, including standard EC2 instances, run x86_64 (amd64). An image built without specifying platform will fail or behave unexpectedly when pulled onto a differently-architected machine. Specify the target platform explicitly at build time when the build and deployment machines are known to differ, for example using docker build --platform linux/amd64, rather than discovering the mismatch only after an attempted deployment fails.

## A Real Operational Detail: Authentication Token Expiry

Registry authentication tokens are not permanent — ECR's default expiry is exactly 12 hours. For occasional manual use, simply re-authenticate when a login error appears. For a production server that must pull automatically without a human present (after a reboot, during an unattended deploy), use a credential helper that fetches a fresh token automatically from an attached IAM Role rather than relying on a manually-run login persisting indefinitely. For CI/CD pipelines, re-authenticate as a normal step in every run, since the token only needs to survive the few minutes a build takes.

## Guardrail Check

Never enable an account-level feature without first checking whether it forces a billing plan change, independent of that feature's own advertised cost. Never leave a registry without a lifecycle policy, even during initial testing — unbounded storage growth is easy to prevent early and tedious to unwind later. Confirm least-privilege boundaries are genuinely enforced by testing an action that should fail, not only testing that intended actions succeed.

## Reference Implementation

See github.com/SwitchhToDevOpsIn90/devops-journey, Session 23 — a real Flask application built on Apple Silicon, pushed to a private ECR repository with a tightly-scoped IAM user, a lifecycle policy limiting retained versions, an avoided IAM Identity Center billing-plan trap, a genuine arm64/amd64 architecture mismatch diagnosed and fixed, and the image successfully pulled and verified running on a real EC2 server via IAM Role authentication.
