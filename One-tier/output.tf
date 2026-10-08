output "vpc_id" {
  value = module.network.vpc_id
}

output "internet_gateway_id" {
  value = module.network.internet_gateway_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "auto_scaling_group_name" {
  value = module.compute.auto_scaling_group_name
}

output "security_group_id" {
  value = module.compute.security_group_id
}

output "availability_zones" {
  value = var.availability_zones
}
