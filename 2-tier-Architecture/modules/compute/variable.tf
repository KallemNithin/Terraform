variable "vpc_id" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "project_name" {
  type = string
}

variable "availability_zone" {
  type = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the Auto Scaling Group"
  type        = list(string)
}

variable "min" {
  default = "2"
}
variable "max" {
  default = "4"
}
variable "desired" {
  default = "3"
}

variable "public_subnet_ids" {
  description = "IDs of public subnets for jumpbox instances"
  type        = list(string)
}