#!/bin/bash

if [[ -z $ANSIBLE_GALAXY_SERVER_CERTIFIED_TOKEN || -z $ANSIBLE_GALAXY_SERVER_VALIDATED_TOKEN ]]
then
    echo "A valid Automation Hub token is required, Set the following environment variables before continuing"
    echo "export ANSIBLE_GALAXY_SERVER_CERTIFIED_TOKEN=<token>"
    echo "export ANSIBLE_GALAXY_SERVER_VALIDATED_TOKEN=<token>"
    exit 1
fi

# log in to pull the base EE image
if ! podman login --get-login registry.redhat.io > /dev/null
then
    echo "Run 'podman login registry.redhat.io' before continuing"
    exit 1
fi

# first positional argument is the EE to build, which will be in its
# own subdirectory
ee_dir=$(basename $1)
if ! pushd ./${ee_dir} >/dev/null
then
    rc=$?
    echo "EE directory does not exist, exiting"
    exit ${rc}
else
    manifest=localhost/${ee_dir}

    # remove prior content
    rm -rf ./context/*

    ansible-builder create \
        --file execution-environment.yml \
        --context ./context \
        -v 3 | tee ansible-builder.log

    # remove existing manifest if present
    _tag=$(date +%Y%m%d)
    podman manifest rm ${manifest}:${_tag}

    # create manifest for EE image
    podman manifest create ${manifest}:${_tag}

    for arch in amd64 arm64
    do
        # build EE for multiple architectures from the EE context
        pushd ./context/ > /dev/null
        podman build --platform linux/${arch} \
          --build-arg ANSIBLE_GALAXY_SERVER_CERTIFIED_TOKEN \
          --build-arg ANSIBLE_GALAXY_SERVER_VALIDATED_TOKEN \
          --manifest ${manifest}:${_tag} . \
          | tee podman-build-${arch}.log
        popd > /dev/null
    done
fi

# inspect manifest content
#podman manifest inspect ${manifest}:${_tag}

# tag manifest as latest
#podman tag ${manifest}:${_tag} ${manifest}:latest

# push all manifest content to repository
# using --all is important here, it pushes all content and not
# just the native platform content
#podman manifest push --all ${manifest}:${_tag}
#podman manifest push --all ${manifest}:latest
