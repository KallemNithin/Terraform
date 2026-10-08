provider "aws" {
  region = var.aws_region
}
module "network" {
  source = "./modules/network"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "compute" {
  source = "./modules/compute"

  project_name       = var.project_name
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  instance_type      = var.instance_type
  desired_capacity   = var.desired_capacity
  min_size           = var.min_size
  max_size           = var.max_size
  ssh_cidr           = var.ssh_cidr
  key_name           = var.key_name
}
