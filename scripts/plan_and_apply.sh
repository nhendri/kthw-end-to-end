#!/bin/bash

SHELL_DIR_LOC=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

source $SHELL_DIR_LOC/set-env.sh

cd $SHELL_DIR_LOC/../provision/kthw && terraform init -upgrade && terraform plan && terraform apply -auto-approve

aws s3 mv s3://kthw-tf-backends/terraform.tfstate s3://kthw-tf-backends/$TF_VAR_cust_id.tfstate

aws dynamodb delete-item \
    --table-name kthw-tf-locktable \
    --key '{"LockID": {"S": "kthw-tf-backends/terraform.tfstate-md5"}}'
