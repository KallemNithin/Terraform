variable "cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "project_name" {
  type = string
  default = "2-tier"
}

variable "public_subnet_cidrs" {
  type = list(string)
  default = [ "10.0.1.0/24","10.0.2.0/24" ]
}

variable "availability_zone" {
  type = list(string)
  default = [ "us-east-1a","us-east-1b" ]
}

variable "private_subnet_cidrs" {
  type = list(string)
  default = [ "10.0.3.0/24","10.0.4.0/24" ]
}


variable "ssh_cidr" {
  description = "CIDR allowed to SSH to instances. Replace with your public IP/32 for better security."
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_name" {
  description = "Optional existing EC2 key pair name. Leave null if SSH key authentication is not required."
  type        = string
  default     = null
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

