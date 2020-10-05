resource "aws_s3_bucket" "demo_bucket" {
  bucket = "my-tf-test-bucketasdasdasd"
  acl    = "public-read"
}

resource "aws_s3_bucket_object" "demo_object" {
  bucket       = "my-tf-test-bucketasdasdasd"
  acl          = "public-read"
  key          = "xo.jpeg"
  source       = "xo.jpeg"
  content_type = "image/jpeg"
  depends_on = [
    aws_s3_bucket.demo_bucket
  ]

}