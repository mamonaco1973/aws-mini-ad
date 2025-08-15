#!/bin/bash

# Check to make sure we can build

export AWS_DEFAULT_REGION=us-east-1  # Required so AWS CLI/Terraform know where to operate

./check_env.sh
if [ $? -ne 0 ]; then
  echo "ERROR: Environment check failed. Exiting."
  exit 1
fi

# Build Phase 1 - Create the AD instance

DNS_ZONE="mcloud.mikecloud.com"

if ! aws ssm get-parameter --name "initialized_$DNS_ZONE" >/dev/null 2>&1; then
  aws ssm put-parameter \
    --name "initialized_$DNS_ZONE" \
    --type String \
    --value "false" \
    --overwrite >/dev/null
fi

cd 01-directory

terraform init
terraform apply -auto-approve

cd ..

# Poll SSM parameter and wait for DC controller to fully initialize before we start using it

while true; do
  STATUS=$(aws ssm get-parameter --name "initialized_$DNS_ZONE" --query "Parameter.Value" --output text)
  if [ "$STATUS" == "true" ]; then
    echo "NOTE: Mini-AD controller is fully initialized."
    break
  fi
  echo "WARNING: Waiting for Mini-AD controller initialization..."
  sleep 30
done

# Build Phase 2 - Create EC2 Instances

cd 02-servers

terraform init
terraform apply -auto-approve

cd .. 

# Build Validation Output

echo ""
./validate.sh

