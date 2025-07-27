
output "vpc_id" {
  description = "The ID of the VPC"
 value = aws_vpc.main.id 
}

output "public_subnet_id" {
    value = aws_subnet.public.id 
}

output "private_subnet_id" {
  value = aws_subnet.private.id 
}

output "public_ec2_ip" {
  value = aws_instance.public_ec2.public_ip
}
