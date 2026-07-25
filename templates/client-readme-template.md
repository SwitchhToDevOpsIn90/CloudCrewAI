# Client Project: REPLACE_ME

## What Was Delivered

Automated server health monitoring for this client's infrastructure.

## Architecture

A scheduled script checks disk usage,
 logs results locally, backs up to S3, and pushes metrics to CloudWatch. An alarm triggers an email alert if usage exceeds the defined threshold.

## Access

AWS IAM user scoped to least privilege, limited to exactly the permissions this monitoring requires.

## Support

For questions about this setup, contact REPLACE_ME.
