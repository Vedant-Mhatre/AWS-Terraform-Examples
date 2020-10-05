variable "region" {
  default = "ap-south-1"
}

variable "s3_bucket_name" {
  default = "my-tf-test-bucketasdasdasd"
}

variable "s3_origin_id" {
  # default = "my-tf-test-bucketasdasdasd.s3.ap-south-1.amazonaws.com"
  default = "myS3Origin"
}

variable "amis" {
  type       = map(string)
  default = {
  ap-south-1 = "ami-0cda377a1b884a1bc"
  us-west-2  = " ami-0947d2ba12ee1ff75"
  }
}