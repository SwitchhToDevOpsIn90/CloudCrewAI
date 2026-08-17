# Playbook: Existing Environment Discovery and Safe Engagement

## WHY

Every other playbook in this framework assumes work begins on something new — a fresh Terraform setup, a new Docker image, a server built from this framework's own patterns. Forward Deployed Engineering and many real client engagements are fundamentally different: arriving in an already-existing, unfamiliar environment that someone else built, often undocumented, often with real production data and real users already depending on it. Applying any other playbook's changes before genuinely understanding what already exists risks breaking something whose importance is not yet understood.

## WHAT This Playbook Delivers

A genuine, verified understanding of an unfamiliar environment's actual current state — what exists, what depends on what, what is safe to touch and what is not — established before any other playbook in this framework is applied to that environment, reducing the risk of a well-intentioned change causing real, unexpected damage.

## Prerequisites

Access credentials to the client's existing environment, granted at whatever scope the client has authorized. Per this framework's guardrails, this playbook is exclusively about observation and understanding — any actual change to the environment happens only after this discovery is complete and follows the relevant guardrail-checked playbook for that specific change.

## Steps

1. Inventory what actually exists before assuming anything based on documentation, prior conversation, or what a similar environment usually looks like — list actual running resources (compute, storage, databases, networking) directly from the cloud provider console or CLI, since documentation drifts from reality over time and this framework treats verified current state as the only reliable source, consistent with its verification-first discipline elsewhere.

2. Identify what is genuinely in active production use, carrying real traffic or real data, versus what appears unused, orphaned, or leftover from earlier work — treat this distinction as provisional until confirmed, not assumed from a resource's name or apparent purpose alone.

3. Map real dependencies between resources before touching any of them — what actually connects to what, which services call which others, which resource's failure would genuinely affect which other part of the system. A resource that appears isolated may still be a genuine dependency for something not immediately visible.

4. Identify existing access patterns and security posture as they actually are, not as they should be — who or what currently has access to what, whether credentials are static or role-based, whether structure matches what this framework's other playbooks would recommend. Do not immediately correct anything found lacking; document it, since fixing a real security gap discovered in an unfamiliar production environment carries its own genuine risk and should follow its own deliberate, reviewed process, not an immediate reflexive fix.

5. Determine what monitoring, alerting, and logging already exists and is actually functioning, distinct from what may be configured but not genuinely working — before assuming a lack of alerts means a lack of problems, confirm alerting is actually operational.

6. Identify the actual owner or point of contact for each major system component where possible, since real institutional knowledge about why something was built a particular way often exists only in a specific person's memory, not in any documentation.

7. Document findings clearly before proposing or making any change, distinguishing explicitly between what was directly verified and what remains uncertain or requires further investigation — an honest "this is confirmed" versus "this appears to be the case but is unverified" distinction matters significantly more in an unfamiliar environment than a newly built one.

8. Only after this discovery is genuinely complete, apply the relevant specific playbook for any actual change needed, informed by what was learned during discovery rather than by this framework's usual default assumptions, which were built around greenfield work.

## Guardrail Check

Never make a configuration change, delete a resource, or modify access during the discovery phase, regardless of how clearly unused or incorrect something appears — discovery is observation only. Never assume an unfamiliar environment follows the same patterns and assumptions this framework's other playbooks are built around; verify explicitly instead. Never skip discovery because a client describes their environment as simple or well-understood — the described understanding and the verified actual state genuinely differ often enough that verification is warranted regardless.

## Reference Implementation

This is a foundational team-operating practice rather than a single traced incident, specifically addressing the gap between this framework's greenfield-oriented playbooks and the genuinely different demands of engaging with an already-existing, unfamiliar client environment — the core skill distinguishing Forward Deployed Engineering and similar client-embedded work from building new infrastructure from scratch.
