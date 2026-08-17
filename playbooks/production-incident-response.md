# Playbook: Production Incident Response

## WHY

A production system going down or degrading is genuinely different from the specific incident types this framework already covers — it is not necessarily a leaked secret (secrets incident response) and not necessarily a deployment needing rollback (release management), though it may turn out to be either. The critical first need during a real incident is fast, calm, structured diagnosis — determining what is actually happening before deciding what to do about it, since acting on an incorrect assumption during an incident often makes things worse, not better.

## WHAT This Playbook Delivers

A calm, structured process for triaging a production issue from first detection through resolution, correctly distinguishing genuine severity from a minor, low-impact issue, and routing to the appropriate specific playbook (release management for a bad deploy, secrets incident response for a credential exposure) once the actual cause is understood — rather than guessing at a fix before genuinely understanding the problem.

## Prerequisites

Monitoring and alerting already in place, per the server monitoring playbook, so an incident is detected rather than only discovered through user reports. Access to relevant logs and metrics for the affected system.

## Steps

1. Confirm the incident is genuinely real before treating it as one — check whether an alert reflects an actual user-facing problem or a monitoring false positive, using the same verification discipline as the free tier verification and vulnerability scanning playbooks: check an independent source before accepting a single signal as ground truth.

2. Assess actual impact honestly and specifically: how many users or what portion of functionality is affected, not a vague sense that "something is wrong" — this determines genuine urgency and whether this is a full incident or a minor issue that can wait for normal-priority investigation.

3. Communicate status honestly and promptly to the human operator the moment genuine impact is confirmed, before root cause is fully understood — an accurate "we know something is wrong and are investigating" is more valuable at this stage than delaying communication until a complete explanation exists.

4. Check recent changes first, specifically anything deployed or configured in the recent window before the incident began — a recent deployment is one of the most common actual root causes, and checking this first is faster than starting from a broad, unfocused investigation.

5. Diagnose using actual evidence from logs and metrics rather than assumption — reproduce or directly observe the actual failure where possible, rather than theorizing about probable causes without checking.

6. Once the actual cause is identified, route to the specific playbook matching that cause: a bad deployment needs the release management playbook's rollback procedure; an exposed credential needs the secrets incident response playbook; a resource exhaustion issue may need the cloud cost optimization playbook's rightsizing guidance applied urgently rather than as scheduled review.

7. After resolution, write a brief, honest record of what happened, the actual root cause, and what will change to prevent recurrence — including adding a new automated test (per the testing and QA playbook) if the specific failure mode was not already covered by an existing test.

## Guardrail Check

Never apply a fix without first confirming the actual root cause through real evidence — acting on a plausible-sounding but unverified theory during an active incident risks masking the real problem or introducing a second issue. Never delay honest status communication to the human operator while waiting for a complete explanation — communicate what is genuinely known as soon as it is known.

## Reference Implementation

This is a foundational team-operating practice rather than a single traced incident, structured to route into this framework's existing, more specific incident playbooks (secrets incident response, release management) once actual root cause is established, rather than duplicating their specific remediation steps here.
