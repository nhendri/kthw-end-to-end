#!/bin/bash

SHELL_DIR_LOC=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

source $SHELL_DIR_LOC/set-env.sh

cd $SHELL_DIR_LOC/../ami/packer && \
    packer init ./main.pkr.hcl && \
    packer validate ./main.pkr.hcl && \
    packer build ./main.pkr.hcl
