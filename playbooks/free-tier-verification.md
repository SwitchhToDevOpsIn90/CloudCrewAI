# Playbook: Free Tier and Cost Verification

## WHY

A client on a free tier or credits-based AWS account can see an alarming Budget or Cost Explorer number and panic, assuming real money is being charged, when the actual bill is zero. Conversely, assuming everything is free without checking is how real surprise charges happen. This playbook exists to get a definitive, real answer either way.

## WHAT This Playbook Delivers

A clear, verified answer to "am I actually being charged real money right now," cross-checked across three independent AWS data sources, plus a concrete number for how much runway (credits and days) remains before that could change.

## Prerequisites

AWS CLI configured with budgets:ViewBudget, ce:GetCostAndUsage, and ec2:DescribeTags permissions (or equivalent read access to Cost Explorer and Budgets for the resources in question).

## Steps

1. Check the AWS Budget status first, if one exists, using aws budgets describe-budget. Note the ActualSpend figure, but do not treat it as final — Budget figures can reflect estimation or credit-accounting rather than confirmed billing.

2. Cross-check against Cost Explorer directly, using aws ce get-cost-and-usage grouped by service. This shows real per-service cost, which is normally the more reliable number for what has actually been billed.

3. If the two numbers disagree, check the actual Billing and Cost Management home page in the AWS Console directly. Look specifically for language like "Your free plan account does not get charged" or "Credits cover your free plan costs" — this is the definitive statement of whether real charges are happening.

4. If on a free credits plan, find and record the exact remaining credit balance and remaining days until expiration, both shown on the same Billing home page.

5. Document all three numbers (Budget ActualSpend, Cost Explorer per-service total, Billing home page real-charge status) together, so the discrepancy itself is understood and not mistaken for a bug or a new problem each time it is checked.

6. Set a concrete, specific follow-up trigger — for example, revisit this check when credits drop below a chosen threshold or days remaining drops below a chosen threshold — rather than leaving cost monitoring as a vague ongoing worry.

## Guardrail Check

Never conclude "this is definitely free, no action needed" based on a single data source alone — always cross-check at least two of the three sources in this playbook before reporting a final answer to a client or to yourself. If any of the three sources are unreachable due to a permissions gap, request the specific missing permission rather than guessing based on partial data.

## Reference Implementation

See github.com/SwitchhToDevOpsIn90/devops-journey, Session 18 — a real case where Budget showed $8.28 ActualSpend, Cost Explorer showed $0.00 real per-service cost, and the Billing home page confirmed zero actual charges due to $131.58 in remaining free plan credits.
