# ========================================
# Lambda
# ========================================
data archive_file "lambda_zip" {
    type = "zip"
    source_file = "${path.module}/src/lambda_handler.py"
    output_path = "${path.module}/src/lambda_handler.zip"
}

resource "aws_lambda_function" "lambda_function" {
  function_name = "${var.project}-${var.environment}-lambda-function"
  filename = data.archive_file.lambda_zip.output_path
  role = aws_iam_role.iam_for_lambda.arn

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  runtime = "python3.10"
  handler = "lambda_handler.lambda_handler"

  timeout = 30
  memory_size = 512
}