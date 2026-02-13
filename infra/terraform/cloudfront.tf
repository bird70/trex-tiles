
resource "aws_cloudfront_cache_policy" "tiles" {
  name        = "${var.project}-tiles"
  default_ttl = 3600
  max_ttl     = 86400
  min_ttl     = 60
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config { cookie_behavior = "none" }
    headers_config { header_behavior = "none" }
    query_strings_config { query_string_behavior = "none" }
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}

resource "aws_cloudfront_distribution" "this" {
  enabled = true
  comment = "${var.project} tiles"

  origins {
    origin_id   = "alb-origin"
    domain_name = aws_lb.this.dns_name
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET","HEAD"]
    cached_methods         = ["GET","HEAD"]
    cache_policy_id        = aws_cloudfront_cache_policy.tiles.id
    compress               = true
  }

  price_class = "PriceClass_200"

  restrictions { geo_restriction { restriction_type = "none" } }

  viewer_certificate {
    acm_certificate_arn      = var.cf_acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  aliases = length(var.domain_name) > 0 ? [var.domain_name] : []
}
