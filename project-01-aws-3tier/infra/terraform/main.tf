data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Repo      = "devops-projects"
  })
}

module "vpc_a" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-vpc-a"
  cidr = var.vpc_a_cidr

  azs             = local.azs
  public_subnets  = [for i, az in local.azs : cidrsubnet(var.vpc_a_cidr, 8, i)]
  private_subnets = [for i, az in local.azs : cidrsubnet(var.vpc_a_cidr, 8, i + 10)]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.common_tags
}

module "vpc_b" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-vpc-b"
  cidr = var.vpc_b_cidr

  azs             = local.azs
  public_subnets  = [for i, az in local.azs : cidrsubnet(var.vpc_b_cidr, 8, i)]
  private_subnets = [for i, az in local.azs : cidrsubnet(var.vpc_b_cidr, 8, i + 10)]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.common_tags
}
