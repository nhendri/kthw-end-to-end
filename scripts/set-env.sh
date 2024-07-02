#!/bin/bash

SHELL_DIR_LOC=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

ENV_FILE=.env-local
if [ -f $SHELL_DIR_LOC/../$ENV_FILE ]; then
    while IFS='=' read -r NAME VALUE; do
    if [ -n "${!NAME}" ]; then
        printf "$NAME has been set\n"
        else
            printf "Setting $NAME from $ENV_FILE\n"
            export "$NAME"="$VALUE"
    fi
    done < $SHELL_DIR_LOC/../$ENV_FILE
fi

ENV_VAR_PUBLIC_KEY_VAR_NAME=TF_VAR_public_key
if [[ -v $ENV_VAR_PUBLIC_KEY_VAR_NAME ]]; then
    printf "$ENV_VAR_PUBLIC_KEY_VAR_NAME has been set\n"
    else
        printf "Setting $ENV_VAR_PUBLIC_KEY_VAR_NAME from local config\n"
        export TF_VAR_public_key=$(cat ~/.ssh/id_rsa.pub)
fi