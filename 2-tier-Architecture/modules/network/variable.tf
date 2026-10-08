variable "cidr_block" {
  type = string
}

variable "project_name" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "availability_zone" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}