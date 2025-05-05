# ========================================
# Lambda
# ========================================

# Lambda 関数を zip 化するためのデータソースを定義する。
# ここでは、lambda_function.py を zip 化して、lambda_function.zip を作成する。
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../src/lambda_function.py"
  output_path = "${path.module}/../src/lambda_function.zip"
}

# Lambda 関数を作成する。
# ここでは、lambda_function.zip を使用して、Lambda 関数を作成する。
resource "aws_lambda_function" "lambda_function" {
  function_name = "${var.project}-${var.environment}-lambda-function"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  filename      = data.archive_file.lambda_zip.output_path
}

resource "aws_lambda_permission" "apigw_invoke_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction" # 関数呼び出しの許可
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com" # API Gateway からの呼び出しを許可

  # API Gateway の ARN を指定することで、特定の API Gateway からの呼び出しを許可
  # 最初の * は リソースパス（例: /fortune）を示し、2番目の * は HTTP メソッド（例: GET, POST）を示す
  source_arn = "${aws_api_gateway_rest_api.rest_api_gw.execution_arn}/*/*"
}