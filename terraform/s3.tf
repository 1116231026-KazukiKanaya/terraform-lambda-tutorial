# ========================================
# S3
# ========================================

# S3 バケットを作成する。
resource "aws_s3_bucket" "frontend_bucket" {
  bucket        = "${var.project}-${var.environment}-frontend-bucket"
  force_destroy = true

  tags = {
    Name        = "${var.project}-${var.environment}-frontend-bucket"
    Project     = var.project
    Environment = var.environment
  }
}

# S3 バケットのアクセス制御を設定する。
resource "aws_s3_bucket_public_access_block" "frontend_bucket_public_access_block" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  depends_on = [
    aws_s3_bucket.frontend_bucket,
  ]
}

# S3 バケットで静的ウェブサイトホスティングを有効にする。
resource "aws_s3_bucket_website_configuration" "frontend_website_config" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html" # SPAなので、ルーティングエラーも index.html で受ける
  }
}

# S3 バケットポリシーを作成する
data "aws_iam_policy_document" "frontend_bucket_policy_document" {
  statement {
    effect    = "Allow"
    sid       = "PublicReadGetObject"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontend_bucket.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

# S3 バケットポリシーをアタッチする
resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket     = aws_s3_bucket.frontend_bucket.id
  policy     = data.aws_iam_policy_document.frontend_bucket_policy_document.json
  depends_on = [aws_s3_bucket_public_access_block.frontend_bucket_public_access_block]
}

# S3 バケットにファイルをアップロードする。
# ここでは、src/frontend/dist ディレクトリ内のすべてのファイルをアップロードする。
# これにより、ファイルが変更された場合に、S3 バケット内のファイルも更新される。
resource "aws_s3_object" "frontend_assets" {

  depends_on = [null_resource.frontend_build]

  bucket = aws_s3_bucket.frontend_bucket.id

  # fileset() 関数を使用して、ディレクトリ内のファイルを取得する。
  for_each = var.deploy_frontend ? fileset("${path.module}/../src/frontend/dist", "**/*") : toset([])

  # key には、S3 バケット内のファイルのパスを指定する。
  key = each.value

  # source には、アップロードするファイルのパスを指定する。
  source = "${path.module}/../src/frontend/dist/${each.value}"

  # etag には、ファイルの内容の MD5 ハッシュ値を指定する。これをすることで、変更の差分を検出できる。
  etag = filemd5("${path.module}/../src/frontend/dist/${each.value}")

  # content_type には、アップロードするファイルの MIME タイプを指定する。
  content_type = lookup({
    html = "text/html"
    css  = "text/css"
    js   = "application/javascript"
    json = "application/json"
    png  = "image/png"
    jpg  = "image/jpeg"
    jpeg = "image/jpeg"
    svg  = "image/svg+xml"
    text = "text/plain"
  }, regex("\\.([^.]*)$", each.value)[0], "binary/octet-stream")

}