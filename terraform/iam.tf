# ========================================
# IAM
# ========================================

# 信頼ポリシーを定義する。信頼ポリシーは、どのエンティティが IAM Role を引き受けることができるかを定義する。
# ここでは、Lambda がこの Role を引き受けることができるように設定する。
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# アクセス許可ポリシーを定義する。ここでは、Lambda に基本的な実行権限を付与するポリシーを使用する。
# AWSLambdaBasicExecutionRole は、CloudWatch Logs への書き込み権限を持つポリシーである。
data "aws_iam_policy" "lambda_basic_exec_policy" {
  name = "AWSLambdaBasicExecutionRole"
}

# IAM Role を作成する。ここでは、Lambda 用の実行ロールを作成する。
# assume_role_policy には、信頼ポリシーを指定することで、Lambda がこの Role を引き受けることができるようにする。
resource "aws_iam_role" "lambda_exec_role" {
  name = "fortune_lambda_exec_role"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags = {
    Name        = "${var.project}-${var.environment}-lambda-exec-role"
    Project     = var.project
    Environment = var.environment
  }
}

# IAM Role にポリシーをアタッチする。
# ここでは、Lambda に基本的な実行権限を付与するポリシーをアタッチする。
resource "aws_iam_role_policy_attachment" "lambda_basic_exec_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = data.aws_iam_policy.lambda_basic_exec_policy.arn
}