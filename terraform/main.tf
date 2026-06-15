provider "aws" {
  region = var.region
}

# Pick an availability zone that's actually usable in this region.
data "aws_availability_zones" "available" {
  state = "available"
}

# Use available subnet
# Local variables
locals {
  name      = var.project
  subnet_id = "subnet-0ec0667985826b173"
  common_tags = merge({
    Project   = var.project
    ManagedBy = "Terraform"
  }, var.tags)
}
