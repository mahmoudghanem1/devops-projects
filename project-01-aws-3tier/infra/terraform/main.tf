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

############################################
# Transit Gateway (TGW)
############################################

resource "aws_ec2_transit_gateway" "this" {
  description                     = "${var.project_name}-tgw"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = merge(var.tags, {
    Name = "${var.project_name}-tgw"
  })
}

# Attach VPC-A to TGW (use PRIVATE subnets)
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_a" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = module.vpc_a.vpc_id
  subnet_ids         = module.vpc_a.private_subnets

  tags = merge(var.tags, {
    Name = "${var.project_name}-tgw-attach-vpc-a"
  })
}

# Attach VPC-B to TGW (use PRIVATE subnets)
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_b" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = module.vpc_b.vpc_id
  subnet_ids         = module.vpc_b.private_subnets

  tags = merge(var.tags, {
    Name = "${var.project_name}-tgw-attach-vpc-b"
  })
}

############################################
# Routes between VPCs via TGW
############################################

# VPC-A private route tables -> route to VPC-B CIDR through TGW
resource "aws_route" "vpc_a_to_vpc_b" {
  for_each               = toset(module.vpc_a.private_route_table_ids)
  route_table_id         = each.value
  destination_cidr_block = var.vpc_b_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.this.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.vpc_a, aws_ec2_transit_gateway_vpc_attachment.vpc_b]
}

# VPC-B private route tables -> route to VPC-A CIDR through TGW
resource "aws_route" "vpc_b_to_vpc_a" {
  for_each               = toset(module.vpc_b.private_route_table_ids)
  route_table_id         = each.value
  destination_cidr_block = var.vpc_a_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.this.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.vpc_a, aws_ec2_transit_gateway_vpc_attachment.vpc_b]
}
