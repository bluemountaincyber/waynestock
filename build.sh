#!/bin/bash

# Build AWS
pushd aws &>/dev/null
export AWS_PROFILE=sec488-j01
terraform init
terraform apply -auto-approve
popd &>/dev/null

# Build Azure
pushd azure &>/dev/null
terraform init
terraform apply -auto-approve
popd &>/dev/null

# Outputs
pushd aws &>/dev/null
terraform output
popd &>/dev/null
pushd azure &>/dev/null
terraform output
popd &>/dev/null
