
# CloudWatch-Metrics-EC2-Monitoring

This project demonstrates the integration of **AWS CloudWatch**, **EC2**, **IAM**, and **SNS** to monitor custom metrics from an **EC2 instance**. It uses the **CloudWatch agent** to collect CPU usage metrics from an EC2 instance running **Ubuntu**, and triggers an alarm when the CPU usage exceeds 90%. The alarm sends an email notification via **SNS**. This setup is useful for monitoring EC2 instances in production environments, ensuring that system performance is always within acceptable thresholds.

## Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Architecture](#architecture)
- [Setup and Installation](#setup-and-installation)
  - [Pre-requisites](#pre-requisites)
  - [Steps to Setup](#steps-to-setup)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Project Overview

The **CloudWatch-Metrics-EC2-Monitoring** project sets up an EC2 instance that runs **Ubuntu** and uses the **CloudWatch agent** to monitor CPU usage. The project leverages **AWS IAM** for secure access control, **CloudWatch** to collect and monitor metrics, and **SNS** to send notifications when an alarm condition is met.

### Key Components:
- **EC2 Instance**: Runs Ubuntu and CloudWatch agent to monitor system metrics.
- **CloudWatch**: Collects and tracks CPU usage metrics.
- **IAM**: Defines roles and policies for secure EC2 instance access to CloudWatch.
- **SNS**: Sends email notifications when the CloudWatch alarm is triggered.
- **CloudWatch Alarms**: Set up to monitor CPU usage and alert when it exceeds 90%.

## Features

- **Custom Metric Monitoring**: Tracks CPU usage on EC2 instances and logs it in CloudWatch.
- **CloudWatch Alarms**: Trigger alarms when CPU usage exceeds the 90% threshold.
- **SNS Notifications**: Sends email alerts to a specified address when alarms are triggered.
- **IAM Roles and Policies**: Securely grants necessary permissions for EC2 and CloudWatch to interact.

## Architecture

The architecture consists of the following flow:

1. **EC2 Instance (Ubuntu)**: The EC2 instance runs the CloudWatch agent, which collects and pushes CPU usage metrics to **CloudWatch**.
2. **CloudWatch Custom Metrics**: The metrics (e.g., `cpu_usage_idle`) are collected by the agent and logged in CloudWatch under the `CustomMetrics` namespace.
3. **CloudWatch Alarms**: The project sets a **CloudWatch alarm** that triggers if CPU usage exceeds 90%.
4. **SNS**: An **SNS topic** is created to send email notifications to a user when the alarm is triggered.

## Setup and Installation

### Pre-requisites
- **AWS Account**: You need an AWS account to create resources such as EC2, IAM, CloudWatch, and SNS.
- **AWS CLI**: Install and configure the AWS CLI for managing your AWS services.
- **Terraform**: This project uses Terraform for provisioning the resources.

### Steps to Setup

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/<your-username>/CloudWatch-Metrics-EC2-Monitoring.git
   cd CloudWatch-Metrics-EC2-Monitoring
   ```

2. **Configure AWS CLI**:
   Make sure your AWS CLI is configured with the correct credentials and region:
   ```bash
   aws configure
   ```

3. **Install Terraform**:
   If you haven’t already installed Terraform, you can do so by running:
   ```bash
   brew install terraform
   ```

4. **Initialize Terraform**:
   Run the following command to initialize the Terraform working directory:
   ```bash
   terraform init
   ```

5. **Apply the Terraform Configuration**:
   To create the resources, apply the Terraform configuration:
   ```bash
   terraform apply
   ```
   Type `yes` when prompted to confirm.

6. **Verify the Resources**:
   - After applying, you should see the EC2 instance running and CloudWatch collecting CPU metrics.
   - The SNS topic will be configured to send email notifications when the CloudWatch alarm is triggered.

## Usage

- Once the EC2 instance is up, it will begin pushing custom metrics (CPU usage) to CloudWatch.
- If CPU usage exceeds 90%, a CloudWatch alarm will be triggered.
- An email notification will be sent to the address provided in the SNS subscription.

To test the setup, you can simulate high CPU usage on the EC2 instance:
```bash
stress --cpu 1 --timeout 60
```
This command will stress the CPU, and if usage exceeds the alarm threshold, the SNS notification will be sent.

## Contributing

We welcome contributions to improve this project. To contribute, please follow these steps:

1. Fork this repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes and commit them (`git commit -am 'Add new feature'`).
4. Push to your branch (`git push origin feature-branch`).
5. Create a pull request.

