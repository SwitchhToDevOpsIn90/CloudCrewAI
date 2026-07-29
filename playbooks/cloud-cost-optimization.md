# Playbook: Cloud Cost Optimization

## WHY

Cloud costs grow silently. Unused resources, oversized instances, and forgotten test environments accumulate charges for months before anyone notices, and clients specifically value this work because it ties technical action directly to a number on their bill.

## WHAT This Playbook Delivers

An automated cost anomaly detection system, a rightsizing recommendation report based on actual usage data, and scheduled shutdown automation for non-production resources — with a documented savings percentage the client can see concretely.

## Prerequisites

AWS Cost Explorer enabled on the account. Read access to billing data and resource utilization metrics. A clear understanding of which resources are production (never touched by shutdown automation) versus non-production (safe to schedule).

## Steps

1. Pull baseline cost data for the trailing 30 to 90 days before making any changes, so improvement is measurable against a real number, not an estimate.

2. Identify genuinely idle or oversized resources using actual CloudWatch utilization metrics, never assumptions. A t3.large sitting at 3 percent CPU for a month is a rightsizing candidate; the same instance at 60 percent is not.

3. Tag every resource clearly as production or non-production before building any automation that acts on that distinction.

4. Build a scheduled Lambda function that stops non-production resources outside business hours and starts them again each morning, using the tags from step 3 to decide what to touch.

5. Set a Cost Anomaly Detection alert in AWS, or build an equivalent Lambda comparing daily spend against a rolling average, alerting when spend spikes unexpectedly.

6. Generate a rightsizing report showing specific instances, their actual utilization, and a recommended smaller size, without automatically resizing anything without review.

7. Document the actual before and after cost comparison once changes have run for at least one full billing cycle, since this concrete number is the most valuable deliverable to a client.

## Guardrail Check

Never automatically stop or resize a resource tagged as production. Never apply a rightsizing recommendation without human review, since utilization data can miss context like planned upcoming load. Confirm the client's billing alarm exists before this playbook even begins, per the general server monitoring playbook.

## Reference Implementation

See AWS Cost Explorer and AWS Compute Optimizer documentation for the underlying data sources this playbook relies on. Client-specific automation should be built as a dedicated Lambda function, version controlled like any other project code.
