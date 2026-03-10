#!/bin/bash

clear

# Variables
SUCCESS="\r[\033[0;32m✓\033[0m]"
FAILURE="\r[\033[0;31m✗\033[0m]"
RED='\033[0;31m'
NC='\033[0m'

# Banner
echo -e '\033[1;36m'
echo '▖  ▖          ▗     ▌   ▄▖▄▖▄▖'
echo '▌▞▖▌▀▌▌▌▛▌█▌▛▘▜▘▛▌▛▘▙▘  ▐ ▌▌▌ '
echo '▛ ▝▌█▌▙▌▌▌▙▖▄▌▐▖▙▌▙▖▛▖  ▟▖▛▌▙▖'
echo '      ▄▌                      '
echo -e '\033[0m'

# Prompt user if they want to proceed
echo -ne "\033[1m\033[4m\033[31mWARNING:\033[0m\033[1m\033[31m This will destroy all infrastructure deployed by this project in AWS. Do you want to proceed? (y/n) \033[0m"
read -n 1 -r
echo
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborting."
    exit 0
fi

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

echo -n "[ ] Creating backend storage account and container... "
RG="AutomationRG"
if ! az group show -n "${RG}" &> /dev/null; then
    az group create -n "${RG}" -l "eastus" &> /dev/null
fi
if ! az group show -n "${RG}" &> /dev/null; then
    echo -e "${FAILURE}"
    echo -e "${RED}Failed to create or access resource group: ${RG}${NC}"
    exit 1
fi
AZURE_SUBSCRIPTION_ID=$(az account show --query "id" -o tsv | tr -d '-')
BACKEND_STORAGE_ACCOUNT="tf${AZURE_SUBSCRIPTION_ID:0:22}"
if ! az storage account show -n "${BACKEND_STORAGE_ACCOUNT}" &> /dev/null; then
    az storage account create -n "${BACKEND_STORAGE_ACCOUNT}" -g "${RG}" -l "eastus" --sku Standard_LRS &> /dev/null
fi
if ! az storage account show -n "${BACKEND_STORAGE_ACCOUNT}" &> /dev/null; then
    echo -e "${FAILURE}"
    echo -e "${RED}Failed to create or access storage account: ${BACKEND_STORAGE_ACCOUNT}${NC}"
    exit 1
fi
BACKEND_CONTAINER="tfstates"
if ! az storage container show -n "${BACKEND_CONTAINER}" --account-name "${BACKEND_STORAGE_ACCOUNT}" &> /dev/null; then
    az storage container create -n "${BACKEND_CONTAINER}" --account-name "${BACKEND_STORAGE_ACCOUNT}" &> /dev/null
fi
if ! az storage container show -n "${BACKEND_CONTAINER}" --account-name "${BACKEND_STORAGE_ACCOUNT}" &> /dev/null; then
    echo -e "${FAILURE}"
    echo -e "${RED}Failed to create or access storage container: ${BACKEND_CONTAINER}${NC}"
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

echo -n "[ ] Applying Terraform configuration (this will take a while)... "
pushd /home/${USER}/waynestock/azure &> /dev/null
/home/${USER}/terraform apply -auto-approve &> /dev/null
if [ $? -eq 0 ]; then
    echo -e "${SUCCESS}"
else
    echo -e "${FAILURE}"
    echo -e "${RED}Failed to apply Terraform configuration.${NC}"
    exit 1
fi
popd &> /dev/null
