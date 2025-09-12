## openshift-ee-demo execution environment image

Execution environment images which include OpenShift-related Ansible content collections require the `openshift-clients` package to be installed during the creation process.  This EE definition includes an example of how to enable the proper RPM repository in the execution-environment.yml file.  Note that a valid OpenShift subscription must be available in your account, and the host where you are running ansible-builder must be subscribed.  See [this KB article](https://access.redhat.com/solutions/7024259) for details.
