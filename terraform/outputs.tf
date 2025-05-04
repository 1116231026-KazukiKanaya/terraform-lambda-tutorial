output "api_gateway_url" {
  description = "The URL of the API Gateway"
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.apigw_stage.stage_name}"
}
