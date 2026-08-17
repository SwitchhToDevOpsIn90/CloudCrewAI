# Playbook: Client Onboarding and Requirements Gathering

## WHY

Every playbook in this framework assumes work has already been scoped and understood. Real engagements do not start there — they start with a client who has a business problem, not a pre-written technical specification. Beginning technical work before genuinely understanding the actual need, constraints, and success criteria produces work that may be technically excellent and still wrong for the client, discovered only after significant effort has already been spent.

## WHAT This Playbook Delivers

A clear, written understanding of what the client actually needs, the real constraints affecting the work (budget, timeline, existing infrastructure, compliance requirements), and an explicit definition of what success looks like — agreed upon before technical work begins, not assumed.

## Prerequisites

Direct communication with the actual client or client stakeholder. Per this framework's guardrails, any client-facing communication requires human operator review before sending — this playbook structures what to gather, not permission to contact a client autonomously.

## Steps

1. Ask what problem is actually being solved, in the client's own words, before proposing any technical approach — a client asking for "a faster website" and a client asking for "fewer abandoned checkouts" may need genuinely different technical work even if both mention performance.

2. Identify real constraints explicitly: budget ceiling, timeline, any existing infrastructure that must be preserved or integrated with, any compliance or data residency requirements, and the client's own team's technical familiarity with whatever will be delivered.

3. Determine who actually has access to what — existing cloud accounts, domain registrars, existing credentials — before assuming provisioning can start immediately, since access gaps discovered mid-engagement cause real delays.

4. Define explicit, measurable success criteria agreed upon with the client, not assumed internally — "the site loads faster" is not measurable; "page load time under 2 seconds for 95 percent of requests" is.

5. Document the agreed scope in writing, including what is explicitly out of scope, before beginning technical work — scope clarity prevents the common pattern of gradually expanding, unbudgeted work.

6. Confirm the client's actual risk tolerance for the specific engagement, since this affects real technical decisions elsewhere in this framework — a client wanting the absolute lowest possible cost accepts different tradeoffs than one prioritizing maximum reliability, and this framework's playbooks (particularly cloud cost optimization and bounded demo provisioning) assume this has already been established.

7. Identify the primary point of contact for ongoing communication and any required approval gates, particularly for actions this framework's guardrails already flag as requiring human review — knowing who approves what before an approval is urgently needed avoids delay at exactly the wrong moment.

## Guardrail Check

Never begin provisioning real infrastructure before scope and budget constraints are explicitly confirmed with the client, even when a technical approach seems obvious. Never assume success criteria the client has not actually stated, even when a default assumption seems reasonable — confirm explicitly instead.

## Reference Implementation

This is a foundational team-operating practice rather than a single traced incident, establishing the discipline that should precede any engagement before other playbooks in this framework are applied to real client work.
