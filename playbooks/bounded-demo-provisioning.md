# Playbook: Bounded Demo Provisioning and Teardown

## WHY

Some real client or portfolio demonstrations genuinely require provisioning an actual cloud resource that has no free tier and real ongoing cost — a Fargate task, a managed database, a load balancer. The value of proving something works on real infrastructure is genuine, but so is the risk of a demo resource being forgotten and quietly accruing cost for days. This playbook exists to get the real proof safely, with the risk bounded to something genuinely negligible.

## WHAT This Playbook Delivers

A real, working demonstration on genuine cloud infrastructure, with verified reachability captured as concrete evidence, and complete, double-verified teardown before the session ends — with the actual cost genuinely bounded and confirmed at each stage, not merely assumed safe because a plan sounded reasonable.

## Prerequisites

A clear, specific reason a bounded real resource is genuinely needed rather than a free-tier alternative — this playbook is for cases where real cost is unavoidable, not a first resort. Direct console or CLI access to tear down every resource type about to be created.

## Steps

1. Before provisioning anything, verify the actual current cost of the smallest viable version of the resource, via search rather than assumption — do not rely on a remembered or estimated figure, since pricing details (and free tier availability) change and vary significantly by resource size and configuration.

2. Choose the smallest resource configuration that still genuinely proves the point — the smallest compute size, no additional supporting infrastructure (a load balancer or NAT gateway, for example) beyond what is strictly necessary for the specific proof being sought.

3. Set an explicit hard cost ceiling before starting, stated as a real dollar figure, even when the actual expected cost is calculated to be far below it — this is a stated safety boundary, not merely a mental estimate.

4. Set an explicit completion rule tied to the working session itself, not a calendar duration — commit to completing provisioning, verification, and teardown within the current active session, since no automated process continues monitoring or cleaning up between sessions.

5. Verify the baseline is genuinely clean before provisioning anything new — confirm no unexpected existing resources of the relevant type, so the starting state is verified rather than assumed.

6. Provision the resource, and the moment it is confirmed reachable, capture the actual real output as evidence immediately — a real terminal response, not a screenshot taken later, since ephemeral resources like a directly-assigned public IP can disappear the instant the resource stops.

7. Tear down every resource created, in reverse order of creation, immediately after evidence is captured — do not leave a working demo running for convenience or to "show someone" later.

8. Verify teardown twice, not once: confirm immediately after executing the teardown steps, then perform a second, fresh verification check afterward before considering the session closed — a second independent check catches anything the first confirmation might have missed, especially at the end of a long session when attention may be lower.

9. Distinguish one-time charges already incurred (a diagnostic tool run, for example) from ongoing resources still requiring teardown — a completed one-time charge needs no further action, while any resource still running needs explicit teardown; conflating the two risks either unnecessary panic or a missed real cleanup step.

10. Confirm actual billing impact as the final step, only after all resource-level teardown is independently verified — billing confirmation validates the outcome, it does not substitute for verifying resources are actually gone.

## Guardrail Check

Never provision a bounded demo resource without first verifying its actual current cost via search, regardless of how confident the estimate feels. Never leave a bounded demo resource running at the end of an active session with the intention of tearing it down "next time" — nothing continues monitoring the account between sessions. Never treat a single teardown confirmation as sufficient without an independent second check, particularly for any resource capable of accruing cost while running.

## Reference Implementation

See github.com/SwitchhToDevOpsIn90/devops-journey, Session 30 — a real Amazon ECS Fargate task provisioned at the smallest available size with no load balancer or NAT gateway, deliberately using a direct public IP for a bounded portfolio demonstration. A real HTTP response was captured as evidence the moment reachability was confirmed. All five created resources (task, cluster, task definition, log group, security group rule) were torn down and independently reverified twice, including a fresh console recheck performed specifically because the session had run long and attention was lower. A one-time diagnostic tool charge was correctly distinguished from the ongoing resources requiring teardown, and final billing confirmation showed zero real cost, fully covered by existing credits.
