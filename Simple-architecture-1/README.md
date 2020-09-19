1. Create VPC
2. Attach Internet Gateway
3. Create one public and one private subnet
4. Create Route Table
5. Associate Route Table for public Subnet
6. Create Security-Group-1 to allow HTTP and SSH from 0.0.0.0/0
7. Create Network-Interface-1 and attach subnet, security group
8. Create Elastic IP and attach to Network-Interface-1
9. Create EC2-1 and attach Network-Interface-1, security-group-1
10. Create Security group to allow SSH from public subnet
11. Create EC2-2 and attach Security-Group-2
12. Create Elastic IP
12. Create Nat Gateway in public subnet and attach EIP
13. Create Route table for private subnet
14. Associate Route table with private subnet
