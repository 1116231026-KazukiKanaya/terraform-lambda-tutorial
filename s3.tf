# ========================================
# S3
# ========================================
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.project}-${var.environment}-lambda-bucket"
}