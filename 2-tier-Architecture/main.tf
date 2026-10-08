provider "aws" {
  region = "us-east-1"
}

module "network" {
  source = "./modules/network/"

  project_name         = var.project_name
  cidr_block           = var.cidr_block
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zone    = var.availability_zone

}

module "compute" {
  source = "./modules/compute"

  project_name       = var.project_name
  vpc_id             = module.network.vpc_id
  instance_type      = var.instance_type
  key_name           = var.key_name
  availability_zone    = var.availability_zone
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_ids  = module.network.private_subnet_ids
  public_subnet_ids = module.network.private_subnet_ids
  

}