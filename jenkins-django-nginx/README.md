
### Prerequisites
* Terraform [(Installtion Process)](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* AWS account
* AWS CLI [(Installation Process)](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)


### Steps to setup:
1. Add your credentials in [vars.tf](vars.tf) file
2. Run ``` terraform apply --auto-approve```


### To-Do:
- [X]  VPC
- [X]  Security Group
- [X] Jenkins Installation
- [X] Nginx Installation
- [X] Certbot Installation
- [ ] Add domain name and setup reverse proxy (optional)
- [x] Clone private git repo by taking credentials through user input
- [x] Modify settings.py to add instance public ip
- [x] Modify gunicorn.service file
- [x] Modify nginx file
- [ ] Add option to use existing vpc,subnets,etc or create new ones
- [ ] Store terraform user input as environment variables
- [ ] Move git clone part into Jenkinsfile and setup CI
- [ ] Write code for testing 
- [ ] Setup email notification for build fail
