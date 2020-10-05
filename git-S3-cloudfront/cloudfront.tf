resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.b.bucket_regional_domain_name
    origin_id   = var.s3_origin_id
    #This value lets you distinguish multiple origins in the same distribution from one another. The description for each origin must be unique within the distribution. 

    custom_origin_config {
      http_port              = 80
      https_port             = 80
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled = true

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
  }

  target_origin_id = var.s3_origin_id
  forwarded_values {
    query_string = false

    cookies {
      forward = "none"
    }
  }

  viewer_protocol_policy = "allow-all"
  min_ttl                = 0
  default_ttl            = 3600
  max_ttl                = 86400


}