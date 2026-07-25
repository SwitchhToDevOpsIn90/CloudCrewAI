# Playbook: Set Up Automated Server Monitoring

## WHY

Every client with a server needs to know if disk space, CPU, or memory is running critically low, before it causes an outage. Manual checking does not scale and gets forgotten.

## WHAT This Playbook Delivers

An automated monitoring script that checks server health on a schedule, uploads logs to durable cloud storage, pushes metrics to a dashboard, and sends an email alert if thresholds are exceeded. Zero manual intervention required after setup.

## Prerequisites

An EC2 instance or equivalent Linux server with AWS CLI installed and configured. An S3 bucket for log backup. IAM permissions scoped to exactly this
 task, nothing more.

## Steps

1. Create an IAM user with least privilege access limited to S3 PutObject, CloudWatch PutMetricData, CloudWatch PutMetricAlarm, SNS Publish, and CloudWatch Logs PutLogEvents. Never use root or an overly broad policy.

2. Create an S3 bucket dedicated to this client's logs, named clearly with the client identifier.

3. Create an SNS topic and subscribe the client's designated contact email for alerts.

4. Write the monitoring script following the pattern in templates, adjusting the disk threshold and server name for this specific client.

5. Test the script manually first, confirming all destinations succeed: local log, S3 upload, CloudWatch metric, CloudWatch Logs.

6. Schedule the script via cron to run every 15 minutes.

7. Create a CloudWatch Dashboard visualizing the key metric.

8. Create a CloudWatch Alarm tied to the SNS topic, triggering when the threshold is exceeded.

9. Document the setup in a client-specific README.

## Guardrail Check

Before executing, confirm guardrails have been reviewed. Do not provision above t3.medium without approval, and confirm a billing alarm exists on the client account first.

## Reference Implementation

See github.com/SwitchhToDevOpsIn90/devops-journey for a complete working example.
