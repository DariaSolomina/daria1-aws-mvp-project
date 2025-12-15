# Key Design Decisions

This document explains the key architectural and design decisions made for the AWS MVP File Storage Service project.

## Architecture Overview

The project implements a three-tier web application architecture on AWS:
- **Presentation Tier**: EC2 instance running Flask web application
- **Application Tier**: Business logic in Flask application
- **Data Tier**: RDS PostgreSQL for metadata, S3 for file storage

## Design Decisions

### 1. VPC Network Design

**Decision**: Use separate public and private subnets in a single VPC

**Rationale**:
- **Public Subnet (10.0.1.0/24, 10.0.2.0/24)**: Hosts web server (EC2) that needs direct internet access
- **Private Subnet (10.0.11.0/24, 10.0.12.0/24)**: Hosts database (RDS) isolated from internet
- **CIDR Block (10.0.0.0/16)**: Provides 65,536 IP addresses for future growth
- **Multi-AZ Subnets**: Two subnets per tier for high availability option

**Trade-offs**:
- ✅ Security: Database not exposed to internet
- ✅ Scalability: Room for additional subnets and resources
- ❌ NAT Gateway disabled for cost savings (limits private subnet internet access)

### 2. Compute: EC2 vs Lambda

**Decision**: Use EC2 instance for Flask application

**Rationale**:
- Flask is a traditional web framework suited for EC2
- Long-running web server model
- More control over environment and dependencies
- Free tier eligible (t3.micro)
- Easier debugging and logging for MVP

**Alternative Considered**:
- AWS Lambda: Better for serverless, event-driven workloads
- Would require API Gateway + Lambda + container/layer for Flask
- Added complexity for MVP phase

### 3. Database: RDS PostgreSQL

**Decision**: Use managed RDS PostgreSQL instead of self-managed database

**Rationale**:
- **Managed Service**: Automatic backups, patching, monitoring
- **PostgreSQL**: Robust, open-source, SQL database
- **Version 12.7**: Stable version with good performance
- **Encryption**: Built-in storage encryption
- **Cost**: Free tier eligible (db.t3.micro)

**Alternative Considered**:
- MySQL/MariaDB: Similar capabilities, chose PostgreSQL for advanced features
- DynamoDB: NoSQL option, but SQL better fits traditional web app patterns
- Self-managed on EC2: More work to manage, patch, and backup

**Trade-offs**:
- ✅ Less operational overhead
- ✅ Built-in backup and recovery
- ✅ Easy to scale
- ❌ Multi-AZ disabled for cost (should enable in production)

### 4. Storage: S3 for Files

**Decision**: Use S3 for file storage instead of EBS volumes

**Rationale**:
- **Scalability**: Unlimited storage capacity
- **Durability**: 99.999999999% (11 9's) durability
- **Cost-Effective**: Pay only for what you use
- **Built-in Features**: Versioning, lifecycle policies, encryption
- **Decoupled**: Not tied to EC2 instance lifecycle

**Features Implemented**:
- AES256 server-side encryption
- Versioning enabled for data protection
- Lifecycle policy: Move to Glacier after 30 days, delete after 365 days
- Public access blocked by default

**Alternative Considered**:
- EBS volumes: Limited by instance size, less durable, harder to share
- EFS: More expensive, overkill for simple file storage

### 5. Security Group Strategy

**Decision**: Separate security groups for EC2 and RDS with minimal required ports

**Rationale**:
- **EC2 Security Group**:
  - SSH (22): Admin access (should restrict to specific IPs in production)
  - HTTP (80): Web traffic
  - HTTPS (443): Secure web traffic
  - All outbound: Allows EC2 to connect to RDS, S3, and updates
  
- **RDS Security Group**:
  - PostgreSQL (5432): Only from EC2 security group
  - No inbound from internet
  - Least privilege principle

**Production Recommendation**:
- Restrict SSH to specific IP addresses or VPN
- Use bastion host for SSH access
- Consider AWS Systems Manager Session Manager (no SSH key needed)

### 6. Terraform State Management

**Decision**: Use S3 backend with DynamoDB state locking

**Rationale**:
- **Remote State**: Team collaboration, state shared across team members
- **S3 Backend**: Durable, versioned storage for state
- **DynamoDB Locking**: Prevents concurrent `terraform apply` operations
- **Encryption**: State file contains sensitive data (encrypted in S3)

**Configuration**:
```hcl
backend "s3" {
  bucket         = "butterfly521113-tf-state"
  key            = "mvp/state"
  region         = "us-west-2"
  dynamodb_table = "terraform-state-lock"
  encrypt        = true
}
```

### 7. Module Structure

**Decision**: Use separate modules for VPC, EC2, RDS, and S3

**Rationale**:
- **Separation of Concerns**: Each module manages one aspect of infrastructure
- **Reusability**: Modules can be reused in different environments
- **Maintainability**: Easier to update one module without affecting others
- **Testing**: Can test modules independently
- **Community Module**: Used `terraform-aws-modules/vpc/aws` for VPC (battle-tested)

**Module Dependencies**:
```
main.tf (root)
├── module.vpc (terraform-aws-modules/vpc/aws)
├── module.ec2 (./modules/ec2) - depends on VPC
├── module.rds (./modules/rds) - depends on VPC and EC2 security group
└── module.s3 (./modules/s3) - independent
```

### 8. IAM Role Design (Conceptual)

**Decision**: EC2 should use IAM role to access S3 (not implemented in current code)

**Rationale**:
- **No Credentials in Code**: Eliminates risk of leaked access keys
- **Automatic Rotation**: IAM role credentials rotate automatically
- **Least Privilege**: Can grant only S3 access needed
- **Audit**: CloudTrail logs all S3 access via role

**Implementation Needed** (Future):
```hcl
resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2-s3-access-role"
  # ... role configuration
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2_s3_role.name
}

# Attach to EC2 instance
resource "aws_instance" "app" {
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  # ... other configuration
}
```

### 9. Monitoring Strategy

**Decision**: Use CloudWatch for centralized monitoring

**Rationale**:
- **Built-in Integration**: Native AWS service
- **Unified Dashboard**: Single pane of glass for all metrics
- **Cost-Effective**: Basic metrics free, detailed metrics low cost
- **Alerting**: Can add CloudWatch Alarms for proactive monitoring

**Metrics Collected**:
- EC2: CPU, network, disk, status checks
- RDS: CPU, connections, storage, read/write IOPS
- S3: Requests, data transfer, storage size

### 10. Cost Optimization

**Decision**: Prioritize free tier and cost-effective options for MVP

**Rationale**:
- **t3.micro instances**: Free tier eligible for first 750 hours/month
- **20GB RDS storage**: Within free tier
- **No NAT Gateway**: Saves ~$30-45/month
- **No Multi-AZ**: Saves ~50% on RDS costs
- **S3 Lifecycle**: Automatic archival to Glacier (90% cost savings)

**Cost Estimates** (us-west-2, on-demand):
- EC2 t3.micro: ~$7.50/month (after free tier)
- RDS db.t3.micro: ~$12/month (after free tier)
- S3 storage: ~$0.023/GB/month
- Data transfer: $0.09/GB (outbound)
- **Total**: ~$20-30/month (after free tier expires)

**Production Considerations**:
- Enable Multi-AZ for RDS: +50% cost, +high availability
- Add NAT Gateway: +$30/month, +private subnet internet access
- Add Application Load Balancer: +$16/month, +scalability
- Add Auto Scaling: Variable cost, +elasticity

### 11. Flask on EC2 Configuration

**Decision**: Run Flask application directly on EC2 with Ubuntu 24.04

**Rationale**:
- **Ubuntu 24.04 LTS**: Long-term support, stable platform
- **Python Ecosystem**: Flask runs natively on Linux
- **Flexibility**: Full control over application stack
- **Simple MVP**: No containers or orchestration complexity

**Deployment Pattern** (Manual for MVP):
1. SSH to EC2 instance
2. Install Python, Flask, dependencies
3. Configure Flask app to connect to RDS
4. Use environment variables for connection strings
5. Run Flask with gunicorn or uWSGI (production server)
6. Configure nginx as reverse proxy (optional)

**Future Enhancement**:
- Use Docker containers for portability
- Implement CI/CD pipeline for automated deployments
- Use Auto Scaling Groups for high availability
- Implement blue-green deployments

### 12. No NAT Gateway for MVP

**Decision**: Disable NAT Gateway in VPC configuration

**Rationale**:
- **Cost Savings**: NAT Gateway costs ~$30-45/month
- **MVP Scope**: Database doesn't need internet access
- **Simple Architecture**: Fewer components to manage

**Implications**:
- Private subnet resources cannot initiate outbound internet connections
- RDS cannot download updates from internet (uses VPC endpoints or maintenance window)
- If needed in future, can enable with: `enable_nat_gateway = true`

**When to Enable**:
- Lambda functions in private subnet need internet
- Private EC2 instances need software updates
- RDS needs external integrations

## Summary of Trade-offs

| Decision | Benefit | Trade-off |
|----------|---------|-----------|
| Public/Private Subnets | Security | Complexity |
| EC2 vs Lambda | Simplicity | Less scalable |
| RDS PostgreSQL | Managed service | Cost higher than self-managed |
| S3 for files | Unlimited, durable | Not filesystem-like |
| No NAT Gateway | Cost savings | No private internet access |
| No Multi-AZ | Cost savings | Lower availability |
| Module structure | Reusability | Initial setup time |
| Remote state | Collaboration | S3/DynamoDB dependency |

## Design Principles Applied

1. **Keep It Simple**: MVP focuses on core functionality
2. **Security First**: Encryption, private subnets, security groups
3. **Cost-Aware**: Free tier and cost-effective choices
4. **Infrastructure as Code**: Everything defined in Terraform
5. **Modularity**: Reusable components
6. **Scalability**: Architecture can grow with minimal refactoring
7. **Best Practices**: Following AWS Well-Architected Framework

## Future Enhancements

Based on this design, future improvements can include:

1. **High Availability**: Multi-AZ RDS, ALB, Auto Scaling
2. **Performance**: CloudFront CDN, RDS read replicas, ElastiCache
3. **Security**: WAF, AWS Shield, VPN access, private endpoints
4. **Monitoring**: Enhanced metrics, X-Ray tracing, custom dashboards
5. **Automation**: CI/CD pipeline, automated testing, infrastructure updates
6. **Disaster Recovery**: Cross-region replication, automated backups
7. **Compliance**: AWS Config, Security Hub, CloudTrail analytics

## References

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [RDS Best Practices](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html)
- [S3 Security Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html)
