# Terraform Validation and Formatting Guide

This guide explains how to validate and format your Terraform code to ensure quality and consistency.

## Prerequisites

- Terraform installed (version >= 1.0)
- AWS CLI configured with credentials
- Access to the AWS account

## Validation Commands

### 1. Terraform Format (`terraform fmt`)

Formats Terraform configuration files to a canonical format and style.

#### Usage

```bash
# Format all .tf files in current directory
terraform fmt

# Format recursively (including subdirectories)
terraform fmt -recursive

# Check if files are formatted (CI/CD use)
terraform fmt -check

# Show diff of formatting changes
terraform fmt -diff
```

#### Example Output

```bash
$ terraform fmt -recursive
main.tf
modules/ec2/main.tf
modules/rds/main.tf
```

#### Best Practices

- Run `terraform fmt -recursive` before committing code
- Add to pre-commit hook to enforce formatting
- Use `-check` in CI/CD pipeline to ensure compliance

### 2. Terraform Validate (`terraform validate`)

Validates the configuration files for syntax errors and internal consistency.

#### Usage

```bash
# Initialize Terraform first (downloads providers)
terraform init

# Validate configuration
terraform validate

# Validate with JSON output (for automation)
terraform validate -json
```

#### Example Output

**Success:**
```bash
$ terraform validate
Success! The configuration is valid.
```

**Error Example:**
```bash
$ terraform validate
Error: Unsupported argument

  on main.tf line 45, in module "web_server":
  45:   invalid_argument = "test"

An argument named "invalid_argument" is not expected here.
```

#### What It Checks

- ✅ Syntax errors in .tf files
- ✅ Valid resource types and arguments
- ✅ Required arguments present
- ✅ Variable types match usage
- ✅ Module dependencies are valid

#### What It Doesn't Check

- ❌ Whether resources will actually be created successfully
- ❌ AWS credentials or permissions
- ❌ Resource naming conflicts in AWS
- ❌ Cost implications

### 3. Terraform Init (`terraform init`)

Initializes a Terraform working directory.

#### Usage

```bash
# Initialize backend and download providers
terraform init

# Upgrade providers to latest versions
terraform init -upgrade

# Reconfigure backend
terraform init -reconfigure

# Skip backend initialization
terraform init -backend=false
```

#### What It Does

1. Downloads and installs provider plugins (e.g., AWS provider)
2. Configures the backend (S3 in our case)
3. Installs module dependencies
4. Creates `.terraform` directory and lock file

#### Example Output

```bash
$ terraform init

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 6.0.0"...
- Installing hashicorp/aws v6.0.0...
- Installed hashicorp/aws v6.0.0 (signed by HashiCorp)

Terraform has been successfully initialized!
```

### 4. Terraform Plan (`terraform plan`)

Creates an execution plan showing what Terraform will do.

#### Usage

```bash
# Show execution plan
terraform plan

# Save plan to file
terraform plan -out=tfplan

# Show plan for specific target
terraform plan -target=module.ec2

# Destroy plan
terraform plan -destroy
```

#### Example Output

```bash
$ terraform plan

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create
  ~ update in-place
  - destroy

Terraform will perform the following actions:

  # module.ec2.aws_instance.app will be created
  + resource "aws_instance" "app" {
      + ami                          = "ami-061b09f4833e8c74a"
      + instance_type                = "t3.micro"
      ...
    }

Plan: 15 to add, 0 to change, 0 to destroy.
```

#### Best Practices

- Always run `terraform plan` before `terraform apply`
- Review changes carefully before applying
- Save plan output for approval workflows
- Use in CI/CD for pull request validation

## Complete Workflow

### Step-by-Step Validation Process

```bash
# 1. Navigate to project directory
cd /path/to/aws-mvp-project

# 2. Format all Terraform files
terraform fmt -recursive

# 3. Initialize Terraform (first time or after provider changes)
terraform init

# 4. Validate configuration syntax
terraform validate

# 5. Check what will be created/changed
terraform plan

# 6. If everything looks good, apply changes
terraform apply
```

### Pre-Commit Checklist

Before committing Terraform code:

- [ ] Run `terraform fmt -recursive`
- [ ] Run `terraform validate`
- [ ] Run `terraform plan` and review output
- [ ] Check for sensitive data in code
- [ ] Update documentation if needed
- [ ] Test changes in dev environment

## Common Validation Errors

### Error 1: Missing Required Argument

```
Error: Missing required argument

  on modules/ec2/main.tf line 5:
   5: resource "aws_instance" "app" {

The argument "ami" is required, but no definition was found.
```

**Solution**: Add the missing required argument.

### Error 2: Invalid Resource Type

```
Error: Invalid resource type

  on main.tf line 10:
  10: resource "aws_invalid_resource" "example" {

The provider hashicorp/aws does not support resource type "aws_invalid_resource".
```

**Solution**: Use correct resource type from AWS provider documentation.

### Error 3: Variable Type Mismatch

```
Error: Invalid value for input variable

The given value is not suitable for var.instance_count, which is expecting a number.
```

**Solution**: Ensure variable value matches the declared type in variables.tf.

### Error 4: Module Source Not Found

```
Error: Module not installed

  on main.tf line 24:
  24: module "vpc" {

This module is not yet installed. Run "terraform init" to install all modules.
```

**Solution**: Run `terraform init` to install module dependencies.

### Error 5: Backend Configuration Error

```
Error: Error loading state

Error: Failed to get existing workspaces: AccessDenied: Access Denied
```

**Solution**: Check AWS credentials and S3 bucket permissions.

## Formatting Standards

### Indentation

Use **2 spaces** for indentation (Terraform standard):

```hcl
resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = var.instance_type
  
  tags = {
    Name = "example-instance"
  }
}
```

### Alignment

Align equals signs for readability:

```hcl
# Good
ami           = var.ami
instance_type = var.instance_type
subnet_id     = var.subnet_id

# Auto-formatted by terraform fmt
```

### Blank Lines

Use blank lines to separate logical blocks:

```hcl
# VPC Configuration
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Subnet Configuration
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Terraform Validation

on: [pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1
        
      - name: Terraform Format Check
        run: terraform fmt -check -recursive
        
      - name: Terraform Init
        run: terraform init -backend=false
        
      - name: Terraform Validate
        run: terraform validate
        
      - name: Terraform Plan
        run: terraform plan
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

### Pre-Commit Hook

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash

echo "Running Terraform fmt..."
terraform fmt -recursive -check
if [ $? -ne 0 ]; then
  echo "Terraform files are not formatted. Run 'terraform fmt -recursive'"
  exit 1
fi

echo "Running Terraform validate..."
terraform validate
if [ $? -ne 0 ]; then
  echo "Terraform validation failed."
  exit 1
fi

echo "All checks passed!"
```

Make it executable:
```bash
chmod +x .git/hooks/pre-commit
```

## Additional Tools

### TFLint

Linter for Terraform to detect errors beyond syntax:

```bash
# Install
brew install tflint  # macOS
# or
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Run
tflint
```

### Terraform-docs

Generate documentation from Terraform modules:

```bash
# Install
brew install terraform-docs  # macOS

# Generate README from module
terraform-docs markdown table modules/ec2/ > modules/ec2/README.md
```

### Checkov

Security and compliance scanner:

```bash
# Install
pip install checkov

# Scan Terraform code
checkov -d .
```

## Best Practices Summary

1. **Always format**: Run `terraform fmt -recursive` before committing
2. **Validate early**: Run `terraform validate` frequently during development
3. **Plan before apply**: Never run `terraform apply` without reviewing plan
4. **Use version control**: Commit .tf files, never commit .tfstate files
5. **Automate checks**: Use CI/CD for automated validation
6. **Document changes**: Update comments and documentation
7. **Test in dev**: Validate changes in development environment first
8. **Review outputs**: Carefully review `terraform plan` output
9. **Use modules**: Keep code DRY with reusable modules
10. **Security scan**: Use tools like Checkov for security best practices

## Troubleshooting

### Issue: `terraform init` fails with backend error

**Solution**:
1. Verify AWS credentials: `aws s3 ls`
2. Check S3 bucket exists: `aws s3 ls s3://butterfly521113-tf-state`
3. Verify DynamoDB table: `aws dynamodb describe-table --table-name terraform-state-lock`
4. Use `terraform init -reconfigure` to reconfigure backend

### Issue: `terraform validate` passes but `terraform plan` fails

**Reason**: `validate` checks syntax, `plan` checks actual AWS API

**Solution**:
1. Check AWS credentials are configured
2. Verify IAM permissions for required actions
3. Check if resources already exist (naming conflicts)
4. Review error message for specific API error

### Issue: Formatting keeps changing

**Reason**: Different Terraform versions format differently

**Solution**:
1. Use same Terraform version across team
2. Specify required version in configuration:
```hcl
terraform {
  required_version = ">= 1.0"
}
```

## References

- [Terraform CLI Documentation](https://www.terraform.io/docs/cli/index.html)
- [Terraform Formatting](https://www.terraform.io/docs/cli/commands/fmt.html)
- [Terraform Validation](https://www.terraform.io/docs/cli/commands/validate.html)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
