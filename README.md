# AAP Execution Environments

This repository contains a set of demo execution environment (EE) image definitions which can be used by the [ansible-builder](https://ansible.readthedocs.io/) tool to create EEs for use with Ansible Automation Platform (AAP).

## Prerequisites

1. An offline token from [Red Hat Automation Hub](https://console.redhat.com/ansible/automation-hub/token) to pull the certified and validated collections (account required)
2. An account to access the container image registry at registry.redhat.io
3. A RHEL 9 system with podman, git, and pip installed
```
sudo dnf install -y podman git-core python3-pip 
```
4. The `ansible-builder` command must be installed, either using the upstream Python package or the ansible-builder RPM from the Ansible Automation Platform RPM repository.

## Building an execution environment image

Each execution environment definition is located in its own subdirectory, and a build script is provided for building an EE based on the directory name.

1. Set the automation hub token environment variables, using the offline token generated on the Red Hat Automation Hub.  This is required when pulling certified or validated collections from Automation Hub.
```
export ANSIBLE_GALAXY_SERVER_CERTIFIED_TOKEN=<your_token>
export ANSIBLE_GALAXY_SERVER_VALIDATED_TOKEN=<your_token>
```
2. Log in to the image registry that provides the base image for the EE.  Typically this will be registry.redhat.io.
```
podman login registry.redhat.io
```
3. Run the build.sh script with the first positional argument being subdirectory that contains the definition for the EE you want to build.  For example:
```
./build.sh network-ee-demo
```
This will create an execution environment image called "localhost/<ee_name>" with a tag based on the current date.  This EE image can then be tagged and pushed to a container registry or to an AAP private automation hub, or it can be saved to an archive (tar file) with `podman image save localhost/<ee_name>:<YYYYMMDD>` as needed.
