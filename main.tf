# Using data source to fetch the AZs from AWS
data "aws_availability_zones" "available" {}

# Cluster Name
locals {
  cluster_name = "EKS-Cluster"
}

# Calling VPC Module
module "vpc" {
  version              = "5.1.1"
  source               = "terraform-aws-modules/vpc/aws"
  name                 = "Demo-VPC"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "Name" = "EKSE-VPC"
  }

  public_subnet_tags = {
    "Name" = "EKS-Public-Subnet"
  }

  private_subnet_tags = {
    "Name" = "EKS-Private-Subnet"
  }
}

# Security Group for worker node
resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "10.0.0.0/8"
    ]
  }
}

# Calling AWS EKS Module
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.0.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.22"
  subnets         = module.vpc.private_subnets
  tags = {
    Name = "Demo-EKS-Cluster"
  }
  vpc_id = module.vpc.vpc_id
  workers_group_defaults = {
    root_volume_type = "gp2"
  }
  worker_groups = [
    {
      name                          = "Worker-Group-1"
      instance_type                 = "t2.micro"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
    {
      name                          = "Worker-Group-2"
      instance_type                 = "t2.micro"
      asg_desired_capacity          = 1
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
  ]
}

# Using data block to fetch the cluster ID
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}
# Using data block to fetch the cluster's Auth ID
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

