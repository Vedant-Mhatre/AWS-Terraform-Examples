resource "aws_s3_bucket" "demo_bucket" {
  bucket = var.s3_bucket_name
  acl    = "public-read"
}

resource "aws_s3_bucket_object" "demo_object" {
  bucket       = var.s3_bucket_name
  acl          = "public-read"
  key          = "xo.jpeg"
  source       = "xo.jpeg"
  content_type = "image/jpeg"
  depends_on = [
    aws_s3_bucket.demo_bucket
  ]

}