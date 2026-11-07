# Independent Verifier (Layer 6)

## Why

The agent that produced the work is the worst judge of it: it remembers what it meant to do, not what is actually true. Reliability rule 6 requires a second pass that did not produce the work. This document makes that pass a defined role with a fixed input, a fixed output and rules that stop it from simply agreeing.

## When it is required

Always for: production changes, security configuration, anything touching client data, deletions and teardowns, and any client-facing report. Optional for low-risk work (documentation, local labs). The operator can require it for anything.

## What the verifier receives (and does not)

Receives: the original request, the definition of "done", the list of claims being made, and read-only access to the real state (or pasted command output). Use `templates/verification-request.md`.

Does not receive: the producer's reasoning, its confidence, or its own "verified" statements. These bias a reviewer toward agreeing.

## What the verifier does

1. Restate each claim as something observable.
2. For each claim, re-read the real state itself with a read-only command or file read. Never rely on the producer's pasted output as the only evidence.
3. Check the opposite direction: look for things that should not exist or should not have changed.
4. Check the labels: any claim presented as confirmed must have evidence the verifier saw; otherwise it is downgraded to inferred or unknown.
5. Check the report against the guardrails (approvals, ceilings, secrets, client-facing promises).
6. Return `templates/verification-report.md`: a verdict per claim (PASS / FAIL / UNVERIFIED), the evidence, and an overall result. Any FAIL or UNVERIFIED claim means the work is not done.

## Rules

- Read-only. The verifier never fixes anything; it reports. Fixing is the producer's job, then verification repeats.
- Default to doubt. A claim with no evidence the verifier can see is UNVERIFIED, not PASS.
- Same facts, fresh eyes: run it as a separate agent or fresh context, never in the producer's session.
- A verifier is not a guarantee. It reduces errors; the accountable human operator still signs off on high-impact work.

## How it was tested

See evals/results/2026-11-07-verifier-test.md (fixture in evals/fixtures/verifier-teardown/) and 2026-11-07-verifier-test-2-hard.md (fixture in evals/fixtures/verifier-teardown-hard/) for the planted-error tests: a report with deliberately false and over-confident claims was given to a fresh agent, and the verdicts were compared against the known answers.
