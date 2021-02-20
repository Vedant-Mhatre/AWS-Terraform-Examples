variable "region" {
  default = "ap-south-1"
}

variable "amis" {
  type = map(string)
}

variable "branchname" {
  type    = string
  default = "uat"
}

variable "reponame" {
  type    = string
  default = "skillmapping/chatbot.git"
}

variable "username" {
  type    = string
  default = "vedant-mhatre"
  # your git username
}

variable "password" {
  type    = string
  default = ""
  # your password
}

variable "projectname" {
  type    = string
  default = "chatbot"
}

variable "appname" {
  type    = string
  default = "chatbot"
}

variable "vpc_id" {
  type = string
  default = "vpc-0e188dd90350c6cc0"
}

variable "subnet_id" {
  type = string
  default = "subnet-0eb854ddc4dc49410"
}

variable "securitygroup_id" {
  type = string
  default = "sg-0e6403cd2b062a3e9"
}