# Automated Infrastructure Provisioning and Configuration System

This repository integrates **AWS**, **Terraform**, **Ansible**, **Jenkins**, and **GitHub App** to create a fully automated infrastructure provisioning and configuration pipeline. It streamlines the orchestration and deployment of AWS resources, such as VPCs, subnets, and EC2 instances, while configuring application services like **Grafana** using Ansible.

---

## Key Features

1. **AWS Infrastructure Provisioning**:
   - Automatically creates VPCs, public and private subnets, security groups, and EC2 instances using **Terraform**.
   - Ensures secure access with SSH keys.
   - Dynamically fetches availability zones and AMIs for scalability.

2. **Application Configuration**:
   - Uses **Ansible playbooks** to install and configure **Grafana** on the provisioned EC2 instances.
   - Automates package installation, service setup, and service start processes.

3. **CI/CD with Jenkins**:
   - Implements a **Jenkins pipeline** to automate the provisioning and configuration workflow.
   - Stages include Terraform initialization, planning, and application of changes.

4. **GitHub Integration**:
   - Utilizes **GitHub App** for secure repository management and triggering Jenkins pipelines.

---

## Repository Structure

- `jenkins/`
  - Contains the `Jenkinsfile` defining the CI/CD pipeline.
- `keys/`
  - Holds the public SSH key required for instance access.
- `playbooks/`
  - Ansible playbooks for configuring application services on the EC2 instance.
- `main.tf`, `providers.tf`, `variables.tf`
  - Terraform files for defining and managing AWS resources.
- `aws_host`
  - Dynamically generated hosts file for Ansible inventory.

---

## How to Use

### Prerequisites
1. Install the following tools:
   - **Terraform**
   - **Ansible**
   - **Jenkins**
   - **AWS CLI**
2. Configure SSH keys and AWS credentials on your local machine.

### Deployment Steps

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/<your-username>/<your-repo>.git
   cd <your-repo>
   ```

2. **Run Jenkins Pipeline**:
   - Open Jenkins and create a new pipeline item.
   - Configure the pipeline with the repository URL.
   - Trigger the pipeline to automate the provisioning and configuration.

   #### Jenkins Pipeline Details
   The provided `Jenkinsfile` executes the following stages:

   - **Checkout**: Clones the GitHub repository to the Jenkins workspace.
   - **Prepare Environment**: Copies and configures the SSH public key for Terraform and Ansible operations.
   - **Terraform Init**: Initializes Terraform to prepare the backend and modules.
   - **Terraform Plan**: Previews the changes Terraform will make to the infrastructure.
   - **Terraform Apply**: Applies the changes, provisioning the AWS resources.

   Post actions:
   - Cleans up temporary files.
   - Displays success or failure messages.

3. **Manual Terraform Deployment** (Optional):
   ```bash
   terraform init
   terraform plan
   terraform apply -auto-approve
   ```

4. **Run Ansible Playbooks**:
   ```bash
   ansible-playbook -i aws_host playbooks/main-playbook.yml
   ```

5. **Access Grafana**:
   - After deployment, use the public IP address and port `3000` (provided in Terraform outputs) to access Grafana.

---

## Terraform Details

The `main.tf` file provisions the following AWS resources:

1. **VPC**:
   - Creates a custom VPC with DNS support.
2. **Subnets**:
   - Defines public and private subnets in multiple availability zones.
3. **Security Groups**:
   - Configures rules for SSH and Grafana access (port 3000).
4. **EC2 Instance**:
   - Provisions an instance with the latest Ubuntu AMI and attaches the public subnet.
5. **Outputs**:
   - Displays the public IP and port for accessing Grafana.

### Example Terraform Output:
```bash
grafana_access = {
  "Demo_main_instance" = "34.207.123.45:3000"
}
```

---

## Ansible Configuration

The playbook `playbooks/main-playbook.yml` automates the installation and setup of Grafana:

1. **Add Grafana Repository**:
   - Adds the official Grafana APT repository and GPG key.
2. **Install Grafana**:
   - Installs Grafana using the APT package manager.
3. **Start Grafana Service**:
   - Ensures the Grafana service is started and enabled at boot.

### Example Playbook Output:
- Confirms successful installation and service status.


