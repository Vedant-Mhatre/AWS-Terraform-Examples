# resource "aws_vpc" "first-vpc" {
#   cidr_block       = "10.0.0.0/16"
#   instance_tenancy = "default"

#   tags = {
#     Name = "dev-vpc"
#   }
# }

# resource "aws_subnet" "subnet-1" {
#   vpc_id            = aws_vpc.first-vpc.id
#   cidr_block        = "10.0.1.0/24"
#   availability_zone = "ap-south-1a"

#   tags = {
#     Name = "public-subnet"
#   }
# }

# resource "aws_internet_gateway" "gw" {
#   vpc_id = aws_vpc.first-vpc.id

#   tags = {
#     Name = "dev-gw"
#   }
# }

# resource "aws_route_table" "r" {
#   vpc_id = aws_vpc.first-vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.gw.id
#   }

#   route {
#     ipv6_cidr_block = "::/0"
#     gateway_id      = aws_internet_gateway.gw.id
#   }

#   tags = {
#     Name = "dev-route-table"
#   }
# }

# resource "aws_route_table_association" "a" {
#   subnet_id      = aws_subnet.subnet-1.id
#   route_table_id = aws_route_table.r.id
# }

# output "vpcid" {
#   value = aws_vpc.first-vpc.id
# }

# output "subid" {
#   value = aws_subnet.subnet-1.id
# }

# output "securityid" {
#   value = aws_security_group.allow-web_traffic-1.id
# }