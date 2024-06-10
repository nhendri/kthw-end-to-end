#!/bin/bash

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "Environment variable AWS_ACCESS_KEY_ID is not set. Exiting."
  exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "Environment variable AWS_SECRET_ACCESS_KEY is not set. Exiting."
  exit 1
fi

if [ -z "$AWS_DEFAULT_REGION" ]; then
  echo "Environment variable AWS_DEFAULT_REGION is not set. Exiting."
  exit 1
fi

if [ ! $(command -v aws)]; then
    echo "AWS CLI is not installed or is not available in the PATH. Exiting."
    exit 1
fi

aws sts get-caller-identity > /dev/null 2>&1
if [$? -ne 0]; then
    echo "AWS CLI Credential appears to be broken. Exiting."
    exit 1
fi

aws ec2 describe-instances
