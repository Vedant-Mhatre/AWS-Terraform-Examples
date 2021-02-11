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
  default = "constituency-dashboard/dashboard-middleware.git"
}

variable "username" {
  type    = string
  default = "vedant-mhatre"
  # your git username
}

variable "password" {
  type    = string
  default = "dBQriYZA4g2xis2"
  # your password
}

variable "projectname" {
  type    = string
  default = "dashboard-middleware"
}

variable "appname" {
  type    = string
  default = "ulb"
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "securitygroup_id" {
  type = string
}