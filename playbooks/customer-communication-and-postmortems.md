# Playbook: Customer Communication and Post-Incident Reports

## WHY

During and after an incident, what is said to customers matters as much as what is fixed. Two mistakes are common and costly: stating a cause as fact before it is confirmed, and promising an outcome nobody can guarantee ("this will never happen again"). Both damage trust far more than an honest "we are still investigating". Because every client-facing message already requires human review under the guardrails, this playbook makes the draft good enough to approve quickly.

## WHAT This Playbook Delivers

Honest, reviewable drafts for incident updates and resolution notices, a blameless post-incident report, and a clear separation of what is confirmed, what is inferred and what is unknown, so the human operator can approve fast and never send something the evidence does not support.

## Prerequisites

The incident facts from production-incident-response.md (timeline, impact, evidence). A human operator who will review and send. Knowledge of who the audience is: the client's team, or the client's own customers.

## Steps

1. Identify the audience and the sender. A message to the client's customers is sent in the client's name and needs the operator's sign-off and usually the client's own approval too. Never send anything yourself; produce a draft.

2. Write the draft from the evidence, not from the request. Include only: what customers experienced, when it started, whether it is resolved, and what is being done. State the cause only at the confidence level you have verified, using the words "confirmed", "we believe" (inferred) or "still investigating" (unknown).

3. If the requester supplies a cause ("it was DNS"), treat it as a claim to check, not a fact. Verify it against independent evidence (provider status pages, resolver and monitoring logs, the timeline). If it cannot be verified, the draft says so, and the operator decides whether to name it.

4. Do not promise outcomes. Replace "it won't happen again" with the concrete prevention steps that exist or are scheduled ("we are adding X and Y to reduce the likelihood of recurrence"). Do not name or blame a third party unless the evidence is confirmed and the operator approves.

5. Keep a cadence for long incidents: initial acknowledgement as soon as impact is confirmed ("we know something is wrong and are investigating"), updates at a stated interval even if nothing has changed, and a resolution notice only after recovery is verified with real checks.

6. Write the blameless post-incident report: summary, impact, timeline (UTC), root cause with confidence label, what went well, what did not, and action items with owners. Focus on systems and process, not individuals.

7. Hand the drafts to the human operator with a short note listing every claim that is inferred or unknown and every commitment the draft makes, so review takes minutes.

## Guardrail Check

Never send any client or customer communication without human review (guardrails file). Never state an unverified cause as fact. Never promise that an incident will not recur. Never blame a third party without confirmed evidence and operator approval. Never include secrets, internal hostnames or account identifiers in a customer message.

## Reference Implementation

Foundational team-operating practice, not yet exercised in a real session. It was added after a blind routing test (see evals/results) in which an agent correctly refused to state an unconfirmed DNS cause and held a customer email for review, but found no playbook to guide the drafting.
