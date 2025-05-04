# ========================================
# API Gateway
# ========================================
resource "aws_apigatewayv2_api" "http_api" {
  name         = "${var.project}-${var.environment}-http-api"
  protocol_type = "HTTP"
  tags = {
    Name        = "${var.project}-${var.environment}-http-api"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id = "${var.project}-${var.environment}-allow-api-gateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri = aws_lambda_function.lambda_function.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "default_api_route" {
  api_id = aws_apigatewayv2_api.http_api.id
  route_key = "POST /predict"
  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id = aws_apigatewayv2_api.http_api.id
  name = "${var.environment}"
  auto_deploy = true
}