![WayneStock logo](azure/webcode/homepage/client/src/images/waynestock-logo.png)

# WayneStock Infrastructure as Code (IaC) Repository

## Deploy AWS

This repository contains Terraform code to deploy and manage the AWS infrastructure for WayneStock. The code is organized into modules and resources that define the necessary components for our cloud environment.

### Prerequisites

- AWS CloudShell instance

### Deployment Steps

1. Clone the repository to your AWS CloudShell instance:

    ```bash
    git clone https://github.com/bluemountaincyber/waynestock.git
    ```

2. Navigate to the AWS directory and run the `deploy-aws.sh` script to deploy the infrastructure:

    ```bash
    cd waynestock/aws
    ./deploy-aws.sh
    ```
