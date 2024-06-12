#!/bin/bash

SHELL_DIR_LOC=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

source $SHELL_DIR_LOC/set-env.sh

cd $SHELL_DIR_LOC/../terraform && terraform init -upgrade && terraform plan && terraform apply -auto-approve
