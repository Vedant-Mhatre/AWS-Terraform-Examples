variable "region" {
  default = "ap-south-1"
}

variable "amis" {
  type = map(string)
  default = {
    ap-south-1 = "ami-0cda377a1b884a1bc"
    us-west-2  = " ami-0947d2ba12ee1ff75"
  }
}