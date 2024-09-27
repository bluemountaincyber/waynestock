#!/bin/bash

# Destroy AWS
pushd aws &>/dev/null
terraform destroy -auto-approve
popd &>/dev/null

# Destroy Azure
pushd azure &>/dev/null
terraform destroy -auto-approve
popd &>/dev/null
