# ========================================
# API Gateway
# ========================================
resource "aws_api_gateway_rest_api" "api" {
  name       = "${var.project}-${var.environment}-api"
}

resource "aws_api_gateway_resource" "fortune" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id = aws_api_gateway_rest_api.api.root_resource_id
  path_part = "fortune"
}

resource "aws_api_gateway_method" "fortune_get" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.fortune.id
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "fortune_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.fortune.id
  http_method = aws_api_gateway_method.fortune_get.http_method

  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.lambda_function.invoke_arn
}

resource "aws_lambda_permission" "apigw_invoke" {
  statement_id = "AllowAPIGatewayInvoke"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_stage" "apigw_stage" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.apigw_deployment.id
}


resource "aws_api_gateway_deployment" "apigw_deployment" {
  depends_on = [
    aws_api_gateway_integration.fortune_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
}
