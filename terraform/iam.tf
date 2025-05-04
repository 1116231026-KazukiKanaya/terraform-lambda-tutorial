# ========================================
# IAM
# ========================================
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.project}-${var.environment}-iam-for-lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags = {
    Name        = "${var.project}-${var.environment}-iam-for-lambda"
    Project     = var.project
    Environment = var.environment
  }
}