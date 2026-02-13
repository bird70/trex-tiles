
output "alb_dns_name" { value = aws_lb.this.dns_name }
output "cloudfront_domain" { value = aws_cloudfront_distribution.this.domain_name }
