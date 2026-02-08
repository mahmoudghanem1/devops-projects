variable "aws_region" { type = string }
variable "project_name" { type = string }

variable "vpc_a_cidr" { type = string }
variable "vpc_b_cidr" { type = string }

variable "az_count" {
  description = "How many AZs to use (2 recommended)"
  type        = number
  default     = 2
}

variable "tags" {
  type    = map(string)
  default = {}
}
