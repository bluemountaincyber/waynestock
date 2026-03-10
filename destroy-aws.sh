#!/bin/bash

# Variables
SUCCESS="\r[\033[0;32m✓\033[0m]"
FAILURE="\r[\033[0;31m✗\033[0m]"
RED='\033[0;31m'
NC='\033[0m'

# Banner
echo "▗▖ ▗▖▗▞▀▜▌▄   ▄ ▄▄▄▄  ▗▞▀▚▖ ▄▄▄  ■   ▄▄▄  ▗▞▀▘█  ▄      ▗▄▖ ▗▖ ▗▖ ▗▄▄▖"
echo "▐▌ ▐▌▝▚▄▟▌█   █ █   █ ▐▛▀▀▘▀▄▄▗▄▟▙▄▖█   █ ▝▚▄▖█▄▀      ▐▌ ▐▌▐▌ ▐▌▐▌   "
echo "▐▌ ▐▌      ▀▀▀█ █   █ ▝▚▄▄▖▄▄▄▀ ▐▌  ▀▄▄▄▀     █ ▀▄     ▐▛▀▜▌▐▌ ▐▌ ▝▀▚▖"
echo "▐▙█▟▌     ▄   █                 ▐▌            █  █     ▐▌ ▐▌▐▙█▟▌▗▄▄▞▘"
echo "           ▀▀▀                  ▐▌                                     "
echo "                                                                      "

# Prompt user if they want to proceed
echo -n "\033[1m\033[4m\033[31mWARNING:\033[0m\033[1m\033[31m This will destroy all infrastructure deployed by this project in AWS. Do you want to proceed? (y/n) \033[0m"
read -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborting."
    exit 0
fi                                                          

# Move to script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

echo -n "[ ] Checking if running in AWS CloudShell... "
if [ -z "$AWS_EXECUTION_ENV" ]; then
    echo -e "${FAILURE}"
    echo -e "${RED}This script must be run in AWS CloudShell. Please open AWS CloudShell and try again.${NC}"
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

echo -n "[ ] Setting AWS region... "
AWS_REGION="us-east-2"
if [ $AWS_REGION != "us-east-2" ]; then
    echo -e "${FAILURE}"
    echo -e "${RED}AWS region is not set to us-east-2. Please set the AWS_REGION variable to us-east-2 and try again.${NC}"
    exit 1
fi
echo -e "${SUCCESS}"

echo -n "[ ] Check for backend bucket... "
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
BACKEND_BUCKET="terraform-state-${AWS_ACCOUNT_ID}"
if ! aws s3 ls "s3://${BACKEND_BUCKET}" &> /dev/null; then
    echo -e "${FAILURE}"
    echo -e "${RED}S3 bucket ${BACKEND_BUCKET} does not exist! Is this the right account?${NC}"
    exit 1
fi
echo -e "${SUCCESS}"

echo -n "[ ] Installing Terraform... "
if ! command -v /home/cloudshell-user/terraform &> /dev/null; then
    curl -sLo /home/cloudshell-user/terraform.zip https://releases.hashicorp.com/terraform/1.14.6/terraform_1.14.6_linux_amd64.zip &> /dev/null
    unzip -o /home/cloudshell-user/terraform.zip terraform -d /home/cloudshell-user &> /dev/null
    rm /home/cloudshell-user/terraform.zip
    if command -v /home/cloudshell-user/terraform &> /dev/null; then
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
pushd /opt/waynestock/aws &> /dev/null
/home/cloudshell-user/terraform init -upgrade -backend-config="bucket=${BACKEND_BUCKET}" -backend-config="key=terraform.tfstate" -backend-config="region=${AWS_REGION}" &> /dev/null
if [ $? -eq 0 ]; then
    echo -e "${SUCCESS}"
else
    echo -e "${FAILURE}"
    echo -e "${RED}Failed to initialize Terraform.${NC}"
    exit 1
fi
popd &> /dev/null

echo -n "[ ] Destroying Terraform-managed infrastructure... "
pushd /opt/waynestock/aws &> /dev/null
/home/cloudshell-user/terraform destroy -auto-approve &> /dev/null
if [ $? -eq 0 ]; then
    echo -e "${SUCCESS}"
else
    echo -e "${FAILURE}"
    echo -e "${RED}Failed to destroy Terraform-managed infrastructure. Try once more.${NC}"
    exit 1
fi
popd &> /dev/null
