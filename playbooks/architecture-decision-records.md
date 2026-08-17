# Playbook: Architecture Decision Records

## WHY

Real engineering decisions between competing approaches (which database, which container orchestrator, which cloud provider) get made under time pressure and are easily forgotten or second-guessed later, especially by someone other than the person who originally decided. A written, structured decision record turns a verbal or in-the-moment choice into something reviewable, defensible, and genuinely useful months later — including to the original decision-maker, who will not remember the exact reasoning by then.

## WHAT This Playbook Delivers

A concise, structured document for any genuine architectural fork in the road, capturing the real options considered, the actual current data used to decide (not assumptions), the decision made, and the reasoning — stored in version control alongside the code it affects, not in a chat log or someone's memory.

## Prerequisites

A genuine decision point between two or more real options, where the choice has lasting consequences on cost, complexity, or direction — not every minor implementation choice warrants an ADR, only ones a future reader would reasonably ask "why did we do it this way."

## Steps

1. Identify the real options honestly, including the option that might be more commonly recommended in general use, even if it will not be chosen — a decision record that only presents the option actually chosen, without a genuine alternative, is not a real decision record.

2. Gather actual current data relevant to the decision rather than relying on general knowledge or memory, especially for anything involving cost or performance — pricing and specifications change, and a decision based on stale figures can be wrong even when the reasoning process was sound.

3. Compare the real options against the criteria that actually matter for this specific decision — cost, complexity relative to the genuine need, team familiarity, portability, and long-term maintenance are common relevant criteria, though not every criterion applies to every decision.

4. State the actual decision clearly and unambiguously — a reader should be able to find the chosen option in one sentence, not have to infer it from a comparison table.

5. Document the reasoning honestly, including any tension or tradeoff being consciously accepted — if the theoretically stronger option was not chosen for a practical reason such as cost, say so plainly rather than only presenting the chosen option's strengths.

6. If the decision creates a deliberate near-term gap against a broader plan or curriculum (choosing a simpler approach now while a more complex, more standard approach is still planned or will still be learned later), state this explicitly, so a future reader does not mistake the decision as a rejection of the broader plan.

7. Store the ADR in version control in a consistent, predictable location (a docs/adr/ directory with sequential numbering is a common convention), committed through the same review workflow as any other change, not as an afterthought exempt from normal process.

## Guardrail Check

Never write an ADR that only justifies a decision already made without genuinely presenting the alternative considered — this produces a document that looks like due diligence without actually being due diligence. Never cite cost or performance figures in an ADR from memory when a quick, current check is available — an ADR is exactly the kind of document that gets referenced later, so stale numbers baked into it cause real problems downstream.

## Reference Implementation

See github.com/SwitchhToDevOpsIn90/devops-journey, Session 28 — a real architecture decision record (docs/adr-001-ecs-vs-eks.md) comparing Amazon ECS and EKS across complexity, cost, and ecosystem, using freshly verified current pricing rather than assumed figures, concluding ECS with Fargate for a specific small application while explicitly noting this was a project-specific decision and did not represent skipping Kubernetes, which remained fully planned later in the curriculum for its genuine industry relevance — directly demonstrating Step 6 of this playbook.
