#!/bin/bash

# Set your region if needed
AWS_DEFAULT_REGION="us-east-1"

windows_dns=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=windows-ad-instance" \
  --query 'Reservations[].Instances[].PublicDnsName' \
  --output text)

linux_dns=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=linux-ad-instance" \
  --query 'Reservations[].Instances[].PublicDnsName' \
  --output text)

echo "NOTE: Windows Instance: $windows_dns"
echo "NOTE: Linux Instance: $linux_dns"