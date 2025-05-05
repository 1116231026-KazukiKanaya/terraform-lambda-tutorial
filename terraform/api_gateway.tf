# ========================================
# API Gateway
# ========================================

# API Gateway を作成する。
resource "aws_api_gateway_rest_api" "rest_api_gw" {
  name        = "${var.project}-${var.environment}-rest-api-gw"
  description = "API Gateway for ${var.project} in ${var.environment} environment"
}

# エンドポイントを作成する。ここでは、/fortune というエンドポイントを作成する。
resource "aws_api_gateway_resource" "fortune" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_gw.id
  parent_id   = aws_api_gateway_rest_api.rest_api_gw.root_resource_id
  path_part   = "fortune"
}

# エンドポイントのメソッドを作成する。ここでは、GET メソッドを作成する。
resource "aws_api_gateway_method" "fortune_get" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_gw.id
  resource_id   = aws_api_gateway_resource.fortune.id
  http_method   = "GET"
  authorization = "NONE"
}

# API GatewayのGETメソッドに対して、Lambdaをバックエンドに統合する。
resource "aws_api_gateway_integration" "fortune_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api_gw.id
  resource_id             = aws_api_gateway_resource.fortune.id
  http_method             = aws_api_gateway_method.fortune_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function.invoke_arn
}

# ----------------------------------------
# CORS（OPTIONS対応）
# ----------------------------------------

# CORSのためのメソッドを作成する。ここでは、OPTIONS メソッドを作成する。
resource "aws_api_gateway_method" "fortune_options" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_gw.id
  resource_id   = aws_api_gateway_resource.fortune.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# API Gateway のエンドポイントに対して、OPTIONS メソッドを呼び出すための統合をする。
# ここでは、MOCK 統合を使用して、実際の Lambda 関数を呼び出さないようにする。
# これにより、API Gateway が CORS ヘッダーを返すことができるようになる。
resource "aws_api_gateway_integration" "fortune_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_gw.id
  resource_id = aws_api_gateway_resource.fortune.id
  http_method = aws_api_gateway_method.fortune_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

# OPTIONS メソッドのレスポンスの型を定義する。
# ここでは、CORS ヘッダーを返すように設定する。
# response_parameters で、レスポンスヘッダーを定義する。
resource "aws_api_gateway_method_response" "fortune_options_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_gw.id
  resource_id = aws_api_gateway_resource.fortune.id
  http_method = aws_api_gateway_method.fortune_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

# OPTIONS メソッドの統合レスポンスを定義する。
# integration_response_parameters で、具体的なヘッダーの値を設定する。
resource "aws_api_gateway_integration_response" "fortune_options_integration_response" {
  depends_on = [
    aws_api_gateway_method_response.fortune_options_response,
  ]
  rest_api_id = aws_api_gateway_rest_api.rest_api_gw.id
  resource_id = aws_api_gateway_resource.fortune.id
  http_method = aws_api_gateway_method.fortune_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.frontend_origin}'"
  }
}
# ----------------------------------------

# API Gateway のデプロイメントを作成する。
# デプロイメントは、API Gateway の変更を反映させるために必要なリソースである。
resource "aws_api_gateway_deployment" "api_gw_deployment" {
  depends_on = [
    aws_api_gateway_integration.fortune_integration,
    aws_api_gateway_integration.fortune_options_integration,
  ]
  rest_api_id = aws_api_gateway_rest_api.rest_api_gw.id
}

# デプロイメントのステージを作成する。ここでは、${var.environment} ステージを作成する。
resource "aws_api_gateway_stage" "api_gw_stage" {
  stage_name    = var.environment
  rest_api_id   = aws_api_gateway_rest_api.rest_api_gw.id
  deployment_id = aws_api_gateway_deployment.api_gw_deployment.id
}