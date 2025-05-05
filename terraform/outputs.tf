output "frontend_site_url" {
  description = "Frontend endpoint URL"
  value       = "http://${aws_s3_bucket_website_configuration.frontend_website_config.website_endpoint}"
}

output "api_endpoint_url" {
  value       = "https://${aws_api_gateway_rest_api.rest_api_gw.id}.execute-api.${var.region}.amazonaws.com/${var.environment}/fortune"
  description = "API Gateway endpoint URL"
}