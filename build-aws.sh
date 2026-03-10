#!/bin/bash

# Variables
SUCCESS="✅"
FAILURE="❌"
RED='\033[0;31m'
NC='\033[0m'

# Move to script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

echo -n "Checking if running in AWS CloudShell... "
if [ -z "$AWS_EXECUTION_ENV" ]; then
    echo "${FAILURE}"
    echo -e "${RED}This script must be run in AWS CloudShell. Please open AWS CloudShell and try again.${NC}"
    exit 1
fi
echo "${SUCCESS}"

echo -n "Calculating available disk space... "
AVAILABLE_DISK_SPACE=$(df /home | tail -1 | awk '{print $4}')
if [ "$AVAILABLE_DISK_SPACE" -lt 1048576 ]; then
    echo "${FAILURE}"
    echo -e "${RED}Available disk space is less than 1GB. Please free up some space and try again.${NC}"
    exit 1
fi
echo "${SUCCESS}"

echo -n "Setting AWS region... "
AWS_REGION="us-east-2"
if [ $AWS_REGION != "us-east-2" ]; then
    echo "${FAILURE}"
    echo -e "${RED}AWS region is not set to us-east-2. Please set the AWS_REGION variable to us-east-2 and try again.${NC}"
    exit 1
fi
echo "${SUCCESS}"

echo -n "Creating backend bucket... "
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
BACKEND_BUCKET="terraform-state-${AWS_ACCOUNT_ID}"
if ! aws s3 ls "s3://${BACKEND_BUCKET}" &> /dev/null; then
    aws s3 mb "s3://${BACKEND_BUCKET}" --region "${AWS_REGION}" &> /dev/null
fi
if ! aws s3 ls "s3://${BACKEND_BUCKET}" &> /dev/null; then
    echo "${FAILURE}"
    echo -e "${RED}Failed to create or access S3 bucket: ${BACKEND_BUCKET}${NC}"
    exit 1
fi
echo "${SUCCESS}"

echo -n "Installing Terraform... "
if ! command -v /home/cloudshell-user/terraform &> /dev/null; then
    curl -sLo /home/cloudshell-user/terraform.zip https://releases.hashicorp.com/terraform/1.14.6/terraform_1.14.6_linux_amd64.zip &> /dev/null
    unzip -o /home/cloudshell-user/terraform.zip terraform -d /home/cloudshell-user &> /dev/null
    rm /home/cloudshell-user/terraform.zip
    if command -v /home/cloudshell-user/terraform &> /dev/null; then
        echo "${SUCCESS}"
    else
        echo "${FAILURE}"
        echo -e "${RED}Failed to install Terraform.${NC}"
        exit 1
    fi
else
    echo "${SUCCESS}"
fi

echo -n "Initializing Terraform... "
pushd /home/cloudshell-user/waynestock/aws &> /dev/null
/home/cloudshell-user/terraform init -var "backend_bucket=${BACKEND_BUCKET}" &> /dev/null
if [ $? -eq 0 ]; then
    echo "${SUCCESS}"
else
    echo "${FAILURE}"
    echo -e "${RED}Failed to initialize Terraform.${NC}"
    exit 1
fi
popd &> /dev/null

echo -n "Applying Terraform configuration (this will take a while)... "
pushd /home/cloudshell-user/waynestock/aws &> /dev/null
/home/cloudshell-user/terraform apply -var "backend_bucket=${BACKEND_BUCKET}" -auto-approve &> /dev/null
if [ $? -eq 0 ]; then
    echo "${SUCCESS}"
else
    echo "${FAILURE}"
    echo -e "${RED}Failed to apply Terraform configuration.${NC}"
    exit 1
fi
popd &> /dev/null
