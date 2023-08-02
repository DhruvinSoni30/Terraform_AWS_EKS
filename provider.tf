# configure aws provider
provider "aws" {
  region  = var.region
  profile = "dhsoni"
}

# configure backend
terraform {
  backend "s3" {
    bucket         = "dhsoni-terraform"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    profile        = "dhsoni"
    dynamodb_table = "terraform-state-lock-dynamodb"
  }
}

# k8s provider
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64encode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}