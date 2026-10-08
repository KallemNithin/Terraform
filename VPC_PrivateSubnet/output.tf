output "private_subnet_ids" {
  value = "${aws_subnet.private[*].id}"
}

output "aws_vpc_id" {
  value = "${aws_vpc.this.id}"
}

output "aws_internet_gateway_id" {
  value = "${aws_internet_gateway.this.id}"
}

output "nat_gateway_id" {
  value = "${aws_nat_gateway.this[*].id}"
}