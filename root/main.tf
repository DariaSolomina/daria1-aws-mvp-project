terraform {
  backend "s3" {
    bucket         = "butterfly521113-tf-state"
    key            = "mvp/state"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
  
  required_providers {
    aws = {
      source       = "hashicorp/aws"
      version      = "~> 6.0.0"
    }
  }
}

provider "aws" {
  region           = var.region
}

data "aws_availability_zones" "available" {}

module "network" {
  source           = "terraform-aws-modules/vpc/aws"
  version          = "6.0.0"

  name             = "mvp-vpc"
  cidr             = "10.0.0.0/16"
  azs              = data.aws_availability_zones.available.names
  public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]         # Public subnets CIDRs
  private_subnets  = ["10.0.11.0/24", "10.0.12.0/24"]       # Private subnets CIDRs
  enable_nat_gateway = false
}


module "storage" {
  source           = "./modules/s3"
  bucket_name      = "mvp-app-storage-${var.env}"
}


module "compute" {
  source           = "./modules/ec2"
  public_subnet_id = module.network.public_subnets[0] # First public subnet
  vpc_id           = module.network.vpc_id
  instance_type    = var.instance_type # EC2 instance type passed dynamically
  ami              = var.ami
  key_name         = var.key_name
}

module "database" {
  source          = "./modules/rds"
  vpc_id          = module.network.vpc_id
  db_subnet_ids   = module.network.private_subnets
  private_subnets = module.network.private_subnets
  app_sg_id       = module.compute.sg_id
  db_username     = var.db_username
  db_password     = var.db_password
  db_instance_class = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
}