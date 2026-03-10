#!/bin/bash

# Variables
SUCCESS="\r[✅]"
FAILURE="\r[❌]"
RED='\033[0;31m'
NC='\033[0m'

echo -n "[ ] Checking if running in Azure Cloud Shell... "
if [ -z "$AZD_IN_CLOUDSHELL" ]; then
    echo -e "${FAILURE}"
    echo -e "${RED}This script must be run in Azure Cloud Shell. Please open Azure Cloud Shell and try again.${NC}"
    exit 1
fi
echo -e "${SUCCESS}"

echo -n "[ ] Calculating available disk space... "
AVAILABLE_DISK_SPACE=$(df / | tail -1 | awk '{print $4}')
if [ "$AVAILABLE_DISK_SPACE" -lt 1048576 ]; then
    echo -e "${FAILURE}"
    echo -e "${RED}Available disk space is less than 1GB. Please free up some space and try again.${NC}"
    exit 1
fi
echo -e "${SUCCESS}"

echo -n "[ ] Checking for backend storage account and container... "
RG="AutomationRG"
if ! az group show -n "${RG}" &> /dev/null; then
    echo -e "${FAILURE}"
    echo -e "${RED}Failed to access resource group: ${RG}${NC}"
    exit 1
fi
AZURE_SUBSCRIPTION_ID=$(az account show --query "id" -o tsv | tr -d '-')
BACKEND_STORAGE_ACCOUNT="tf${AZURE_SUBSCRIPTION_ID:0:22}"
if ! az storage account show -n "${BACKEND_STORAGE_ACCOUNT}" &> /dev/null; then
    echo -e "${FAILURE}"
    echo -e "${RED}Failed to access storage account: ${BACKEND_STORAGE_ACCOUNT}${NC}"
    exit 1
fi
BACKEND_CONTAINER="tfstates"
if ! az storage container show -n "${BACKEND_CONTAINER}" --account-name "${BACKEND_STORAGE_ACCOUNT}" &> /dev/null; then
    echo -e "${FAILURE}"
    echo -e "${RED}Failed to access storage container: ${BACKEND_CONTAINER}${NC}"
    exit 1
fi
echo -e "${SUCCESS}"

echo -n "[ ] Installing Terraform... "
if ! command -v /home/${USER}/terraform &> /dev/null; then
    curl -sLo /home/${USER}/terraform.zip https://releases.hashicorp.com/terraform/1.14.6/terraform_1.14.6_linux_amd64.zip &> /dev/null
    unzip -o /home/${USER}/terraform.zip terraform -d /home/${USER} &> /dev/null
    rm /home/${USER}/terraform.zip
    if command -v /home/${USER}/terraform &> /dev/null; then
        echo -e "${SUCCESS}"
    else
        echo -e "${FAILURE}"
        echo -e "${RED}Failed to install Terraform.${NC}"
        exit 1
    fi
else
    echo -e "${SUCCESS}"
fi

echo -n "[ ] Initializing Terraform... "
pushd /home/${USER}/waynestock/azure &> /dev/null
/home/${USER}/terraform init -upgrade -backend-config="resource_group_name=${RG}" -backend-config="storage_account_name=${BACKEND_STORAGE_ACCOUNT}" -backend-config="container_name=${BACKEND_CONTAINER}" -backend-config="key=terraform.tfstate" &> /dev/null
if [ $? -eq 0 ]; then
    echo -e "${SUCCESS}"
else
    echo -e "${FAILURE}"
    echo -e "${RED}Failed to initialize Terraform.${NC}"
    exit 1
fi
popd &> /dev/null

echo -n "[ ] Destroying Terraform-managed infrastructure (this will take a while)... "
pushd /home/${USER}/waynestock/azure &> /dev/null
/home/${USER}/terraform destroy -auto-approve &> /dev/null
if [ $? -eq 0 ]; then
    echo -e "${SUCCESS}"
else
    echo -e "${FAILURE}"
    echo -e "${RED}Failed to destroy Terraform-managed infrastructure. Try once more.${NC}"
    exit 1
fi
popd &> /dev/null
