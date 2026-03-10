![WayneStock logo](azure/webcode/homepage/client/src/images/waynestock-logo.png)

# WayneStock Infrastructure as Code (IaC) Repository

## Deploy AWS

This repository contains Terraform code to deploy and manage the AWS infrastructure for WayneStock. The code is organized into modules and resources that define the necessary components for our cloud environment.

### Prerequisites

- AWS CloudShell instance

### Deployment Steps

1. Clone the repository to your AWS CloudShell instance into `/opt/waynestock` and change ownership to your user:

    ```bash
    sudo git clone https://github.com/bluemountaincyber/waynestock.git /opt/waynestock
    sudo chown -R $USER:$USER /opt/waynestock
    ```

2. Navigate to the AWS directory and run the `build-aws.sh` script to deploy the infrastructure:

    ```bash
    cd /opt/waynestock
    ./build-aws.sh
    ```

### Destruction Steps

1. Clone the repository to your AWS CloudShell instance and change ownership to your user if you haven't already:

    ```bash
    sudo git clone https://github.com/bluemountaincyber/waynestock.git /opt/waynestock
    sudo chown -R $USER:$USER /opt/waynestock
    ```

2. Navigate to the AWS directory and run the `destroy-aws.sh` script to destroy the infrastructure:

    ```bash
    cd /opt/waynestock
    ./destroy-aws.sh
    ```
