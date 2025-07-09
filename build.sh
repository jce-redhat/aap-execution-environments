#!/bin/bash

if [[ -z $ANSIBLE_GALAXY_SERVER_CERTIFIED_TOKEN || -z $ANSIBLE_GALAXY_SERVER_VALIDATED_TOKEN ]]
then
    rc=$?
    echo "A valid Automation Hub token is required, Set the following environment variables before continuing"
    echo "export ANSIBLE_GALAXY_SERVER_CERTIFIED_TOKEN=<token>"
    echo "export ANSIBLE_GALAXY_SERVER_VALIDATED_TOKEN=<token>"
    exit ${rc}
fi

if ! type ansible-builder
then
    rc=$?
    echo "ansible-builder program must be installed before continuing"
    exit ${rc}
fi

# first positional argument is the EE to build, which will be in its
# own subdirectory
ee_name=$(basename $1)
if ! pushd ./${ee_name} >/dev/null
then
    rc=$?
    echo "EE directory does not exist, exiting"
    exit ${rc}
else
    # remove prior context
    rm -rf ./context/*

    # use date as tag name
    ee_tag=$(date +%Y%m%d)
    ansible-builder build \
        --context ./context \
        --build-arg ANSIBLE_GALAXY_SERVER_CERTIFIED_TOKEN \
        --build-arg ANSIBLE_GALAXY_SERVER_VALIDATED_TOKEN \
        -v 3 \
        -t localhost/${ee_name}:${ee_tag} | tee ansible-builder.log
fi
