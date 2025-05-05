# ========================================
# Build the frontend application
# ========================================
resource "null_resource" "frontend_build" {
  count = var.deploy_frontend ? 1 : 0

  provisioner "local-exec" {
    working_dir = "${path.module}/../src/frontend"
    command     = "npm install && npm run build"
  }

  triggers = {
    build_id = timestamp()
  }
}