# 🚀 Terraform AWS Web Infrastructure

> Highly Available AWS Web Infrastructure deployed with Terraform — spanning multiple Availability Zones with automated EC2 setup, Application Load Balancing, and S3 storage.

---

## 📌 Architecture Overview

```
                         ┌──────────────────────┐
                         │       Internet        │
                         └──────────┬───────────┘
                                    │
                         ┌──────────▼───────────┐
                         │  Application Load     │
                         │  Balancer (ALB)       │
                         │  Port 80 (HTTP)       │
                         └────────┬──────┬───────┘
                                  │      │
               ┌──────────────────┘      └──────────────────┐
               │                                            │
    ┌──────────▼──────────┐                    ┌───────────▼──────────┐
    │   EC2 - Server 1    │                    │   EC2 - Server 2     │
    │  Availability Zone 1│                    │  Availability Zone 2 │
    │  Ubuntu + Nginx     │                    │  Ubuntu + Nginx      │
    │  Public Subnet 1    │                    │  Public Subnet 2     │
    └─────────────────────┘                    └──────────────────────┘
               │                                            │
    ┌──────────▼────────────────────────────────────────────▼──────────┐
    │                         Custom VPC                                │
    │         Internet Gateway + Route Tables + Security Groups         │
    └───────────────────────────────────────────────────────────────────┘
                                    │
                         ┌──────────▼───────────┐
                         │     Amazon S3         │
                         │   (Object Storage)    │
                         └──────────────────────┘
```

Traffic enters through the **Application Load Balancer**, which distributes requests across two EC2 instances sitting in separate Availability Zones. This design ensures **high availability and fault tolerance** — if one AZ goes down, the other continues serving traffic uninterrupted.

---

## 🏗️ Infrastructure Components

### 🔷 Networking

| Resource | Details |
|----------|---------|
| VPC | Custom Virtual Private Cloud with a dedicated CIDR block |
| Public Subnets | 2 subnets spread across 2 separate Availability Zones |
| Internet Gateway | Enables outbound and inbound internet connectivity |
| Route Tables | Custom route tables associated with each public subnet |
| Route Associations | Explicit subnet-to-route-table associations for traffic control |

- **VPC isolation** ensures all resources live in a controlled network boundary.
- **Public subnets** in different AZs are the backbone of the high-availability setup.
- **Internet Gateway** is attached to the VPC and referenced in the route table to allow internet-facing traffic.

---

### 💻 Compute

| Resource | Details |
|----------|---------|
| EC2 Instance 1 | Ubuntu AMI deployed in AZ-1, bootstrapped via `userdata.sh` |
| EC2 Instance 2 | Ubuntu AMI deployed in AZ-2, bootstrapped via `userdata1.sh` |
| Web Server | Nginx installed and configured automatically on launch |
| Web Content | Each instance serves a unique portfolio-style HTML page |

- Instances are launched using **User Data scripts** that run on first boot, handling package updates, Nginx installation, and web page deployment — no manual SSH required.
- Each EC2 instance is placed in a different AZ, so a zone failure doesn't take both servers offline.

---

### ⚖️ Load Balancing

| Resource | Details |
|----------|---------|
| Application Load Balancer | Internet-facing ALB spanning both public subnets |
| Target Group | Registers both EC2 instances as targets for the ALB |
| Health Checks | Periodic HTTP checks ensure traffic only routes to healthy instances |
| HTTP Listener | Listens on Port 80 and forwards traffic to the Target Group |

- The ALB operates at **Layer 7 (HTTP/HTTPS)**, making routing decisions based on request content.
- **Health checks** automatically detect and remove unhealthy instances from the rotation, preventing traffic from reaching broken servers.
- Refreshing the ALB URL alternates between Server 1 and Server 2, visually confirming round-robin load balancing.

---

### 🛡️ Security

| Resource | Details |
|----------|---------|
| Security Group | Applied to both EC2 instances and the ALB |
| Inbound SSH | Port 22 open for administrative access |
| Inbound HTTP | Port 80 open for web traffic |
| Outbound | All outbound traffic permitted (for package installs, updates) |

> ⚠️ **Note:** Port 22 (SSH) is open to all IPs in this demo setup. In production, restrict SSH access to specific trusted IP ranges using CIDR notation.

---

### 🗄️ Storage

| Resource | Details |
|----------|---------|
| Amazon S3 Bucket | Provisioned as part of the infrastructure stack |

- The S3 bucket is created alongside the rest of the infrastructure via Terraform.
- Planned use includes static website hosting (see Planned Improvements).

---

## 📁 Project Structure

```
terraform-aws-web-infrastructure/
├── main.tf           # Core infrastructure: VPC, Subnets, IGW, EC2, ALB, S3, Security Groups
├── provider.tf       # AWS provider configuration and region settings
├── variables.tf      # Parameterized inputs: AMI IDs, instance types, CIDR blocks, etc.
├── userdata.sh       # Bootstrap script for EC2 Server 1 (Nginx setup + HTML page)
├── userdata1.sh      # Bootstrap script for EC2 Server 2 (Nginx setup + HTML page)
└── README.md         # Project documentation
```

### File Descriptions

**`main.tf`**
The heart of the project. Defines all AWS resources including the VPC, subnets, internet gateway, route tables, security groups, EC2 instances, ALB, target group, listener, and S3 bucket. Resources are interconnected using Terraform references (e.g., `aws_vpc.main.id`).

**`provider.tf`**
Specifies the AWS provider and region. Ensures Terraform knows which cloud and region to deploy resources into. Locks the provider version for reproducibility.

**`variables.tf`**
Centralizes configurable values to avoid hardcoding in `main.tf`. Makes it easy to reuse the project across environments by changing a single file.

**`userdata.sh` / `userdata1.sh`**
Shell scripts executed automatically when each EC2 instance first boots. Each script:
1. Updates the package list
2. Installs Nginx
3. Writes a custom HTML page identifying which server is responding
4. Starts and enables the Nginx service

---

## ⚙️ Tech Stack

| Tool / Service | Role in the Project |
|---------------|---------------------|
| **Terraform** | Provisions and manages all infrastructure as code |
| **AWS EC2** | Hosts the Ubuntu virtual servers running Nginx |
| **AWS VPC** | Provides network isolation and custom routing |
| **AWS ALB** | Distributes incoming HTTP traffic across both EC2 instances |
| **AWS S3** | Object storage bucket provisioned alongside the stack |
| **Ubuntu Linux** | OS for EC2 instances |
| **Nginx** | Lightweight, high-performance web server |
| **GitHub** | Source control and version management |

---

## 🚀 Deployment Guide

### Prerequisites

Before deploying, ensure you have the following:

- **Terraform** v1.0+ installed — [Download here](https://developer.hashicorp.com/terraform/downloads)
- **AWS CLI** installed and configured — run `aws configure` with your access key, secret key, and region
- **AWS IAM permissions** for: EC2, VPC, ALB (Elastic Load Balancing), S3, and IAM (for security groups)
- A valid **key pair** configured in your target AWS region (if SSH access is needed)

---

### Step 1 — Clone the Repository

```bash
git clone https://github.com/CH-Nithin-Reddy/terraform-aws-web-infrastructure.git
cd terraform-aws-web-infrastructure
```

---

### Step 2 — Initialize Terraform

```bash
terraform init
```

This downloads the AWS provider plugin and prepares the working directory. You should see:

```
Terraform has been successfully initialized!
```

---

### Step 3 — Validate Configuration

```bash
terraform validate
```

Checks your `.tf` files for syntax errors and configuration validity without making any AWS API calls. Expected output:

```
Success! The configuration is valid.
```

---

### Step 4 — Preview Changes

```bash
terraform plan
```

Generates an execution plan showing every resource Terraform will create, modify, or destroy. Review this carefully before proceeding. Look for:

- Resources marked with `+` (will be created)
- Resources marked with `~` (will be modified)
- Resources marked with `-` (will be destroyed)

---

### Step 5 — Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when prompted. Terraform will provision all AWS resources in the correct order, respecting dependencies (e.g., the VPC is created before subnets, subnets before EC2 instances).

Typical provisioning time: **2–5 minutes**

---

### Step 6 — Access the Application

After a successful apply, Terraform outputs the ALB DNS name:

```
Outputs:

loadbalancerdns = "http://myalb-123456789.us-east-1.elb.amazonaws.com"
```

Open the URL in your browser. **Refresh the page multiple times** — you'll see the response alternate between Server 1 and Server 2, confirming the load balancer is working correctly.

> ⚠️ **Allow 2–3 minutes** after `terraform apply` completes for the EC2 instances to finish their User Data bootstrapping and pass ALB health checks before the URL becomes accessible.

---

## 🧹 Destroy Infrastructure

Always clean up resources when done to avoid unnecessary AWS charges:

```bash
terraform destroy
```

Type `yes` when prompted. Terraform will tear down all provisioned resources in reverse dependency order.

> ⚠️ **Important:** This is irreversible. Ensure you don't need any of the resources before running destroy. S3 buckets with content may require manual emptying first.

---

## 🔍 How It Works — End to End

1. **Terraform reads** all `.tf` files and builds a dependency graph of resources.
2. **VPC and networking** resources are created first (VPC → Subnets → Internet Gateway → Route Tables).
3. **Security Groups** are defined to control traffic in/out of EC2 instances.
4. **EC2 instances** are launched in separate AZs. User Data scripts automatically install Nginx and deploy web pages on boot.
5. **ALB is provisioned** spanning both public subnets, with a Target Group pointing to both EC2 instances.
6. **Health checks** run against each instance. Once they pass, the ALB begins routing traffic.
7. **S3 bucket** is created alongside the infrastructure for future use.
8. **ALB DNS name** is output by Terraform for immediate access.

---

## ✅ Features Demonstrated

- ✔ **Infrastructure as Code** — entire stack defined and versioned in Terraform
- ✔ **High Availability** — EC2 instances distributed across multiple Availability Zones
- ✔ **Application Load Balancing** — HTTP traffic distributed with health-check-aware routing
- ✔ **Automated EC2 Bootstrapping** — Nginx installed and configured via User Data (no manual setup)
- ✔ **Security Group Configuration** — Controlled inbound/outbound rules at the instance level
- ✔ **Version Control** — Full infrastructure history tracked via GitHub

---

## 🎯 Key Learnings

### Terraform Workflow
The standard Terraform lifecycle: `init → validate → plan → apply → destroy`. Each step serves a purpose — validating before applying prevents costly mistakes, and planning before applying gives full visibility into changes.

### AWS Networking Fundamentals
- **VPC**: Isolated network boundary for all resources
- **Subnets**: Subdivisions of the VPC; public subnets have routes to the Internet Gateway
- **Internet Gateway**: The bridge between your VPC and the public internet
- **Route Tables**: Determine where network traffic is directed within the VPC

### Application Load Balancer
- ALBs operate at Layer 7 and can route based on URL path, host headers, or query strings
- **Target Groups** decouple the ALB from the actual backend instances, enabling flexible scaling
- **Health checks** are critical — they prevent traffic from reaching unhealthy servers

### EC2 Automation with User Data
User Data scripts run as `root` on first launch, making them powerful for zero-touch configuration. They're Base64-encoded and passed to the instance at boot time via the AWS metadata service.

### High Availability Design
Spreading resources across multiple Availability Zones is the foundational pattern for fault-tolerant AWS architecture. AZs are physically separate data centers, so failures are isolated.

---

## 🔭 Planned Improvements

| Feature | Description |
|---------|-------------|
| **HTTPS with ACM SSL** | Issue a free SSL certificate via AWS Certificate Manager and add an HTTPS listener (port 443) to the ALB |
| **Auto Scaling Group** | Replace static EC2 instances with an ASG that scales in/out based on CPU or request load |
| **S3 Static Website** | Host the frontend assets on the existing S3 bucket with static website hosting enabled |
| **CI/CD Pipeline** | Automate `terraform plan` and `terraform apply` via GitHub Actions on push to main |
| **CloudWatch Monitoring** | Set up dashboards, alarms, and log groups for EC2 CPU, ALB request count, and target health |
| **Remote Terraform State** | Store `terraform.tfstate` in an S3 bucket with DynamoDB state locking for team collaboration |
| **WAF Integration** | Attach AWS WAF to the ALB to filter malicious traffic and protect against common exploits |
| **Private Subnets** | Move EC2 instances into private subnets with a NAT Gateway, exposing only the ALB publicly |

---

## 💡 Common Issues & Troubleshooting

**ALB URL returns 502 Bad Gateway**
The EC2 instances may still be bootstrapping. Wait 2–3 minutes and retry. You can check the User Data logs via EC2 Instance Connect: `cat /var/log/cloud-init-output.log`

**Terraform apply fails with permissions error**
Ensure your IAM user/role has the required permissions: `ec2:*`, `elasticloadbalancing:*`, `s3:*`, `vpc:*`. Attach `AdministratorAccess` for testing (not recommended for production).

**Health checks failing in Target Group**
Verify Nginx is running on the instance (`sudo systemctl status nginx`) and the Security Group allows inbound traffic on port 80 from the ALB's security group.

**`terraform destroy` fails on S3 bucket**
S3 buckets must be empty before deletion. Either empty the bucket manually in the console or add `force_destroy = true` to the S3 bucket resource in `main.tf`.

---

## 📎 References

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC User Guide](https://docs.aws.amazon.com/vpc/latest/userguide/)
- [AWS Application Load Balancer Docs](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- [EC2 User Data Guide](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html)
- [Terraform Best Practices](https://developer.hashicorp.com/terraform/tutorials/aws-get-started)
