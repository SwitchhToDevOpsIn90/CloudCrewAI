#!/bin/bash
# Monitoring Script Template
# Copy this file, rename it, and customize the values below for each client.

CLIENT_NAME="REPLACE_ME"
DISK_LIMIT=80
DATE=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="monitoring.log"
S3_BUCKET="REPLACE_ME"

set -e

DISK_USED=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

if [ "$DISK_USED" -gt "$DISK_LIMIT" ]; then
    echo "WARNING: Disk at ${DISK_USED} percent for ${CLIENT_NAME}"
else
    echo "OK: Disk is safe for ${CLIENT_NAME}"
fi

echo "$DATE Disk ${DISK_USED} percent" >> "$LOG_FILE"
aws s3 cp "$LOG_FILE" "s3://${S3_BUCKET}/${LOG_FILE}"
aws cloudwatch put-metric-data --namespace "Monitoring" --metric-name "DiskSpaceUtilization" --value "$DISK_USED" --unit Percent
