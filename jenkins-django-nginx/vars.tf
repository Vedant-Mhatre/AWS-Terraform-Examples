variable "region" {
  default = "ap-south-1"
}
variable "amis" {
  type = map(string)
}

variable "branchname" {
  default = "uat"
}

variable "reponame" {
  default = "constituency-dashboard/dashboard-middleware.git"
}

variable "username" {
  default = "abcd"
  # your git username
}

variable "password" {
  default = "abcd"
  # your password
}

variable "projectname" {
  default = "dashboard-middleware"
}

variable "appname" {
  default = "ulb"
}