resource "terraform_data" "bootstrap" {
  # コンテナか volume を作り直したら Forgejo のデータも消えているので、やり直す
  triggers_replace = [var.container_name, var.secrets_volume_name]

  provisioner "local-exec" {
    command     = "${path.module}/bootstrap.sh"
    interpreter = ["bash"]
    environment = {
      CONTAINER              = var.container_name
      SECRETS_VOLUME         = var.secrets_volume_name
      ADMIN_USERNAME         = var.admin_username
      ADMIN_EMAIL            = var.admin_email
      ADMIN_PASSWORD         = var.admin_password
      SERVICE_USERNAME       = var.service_username
      SERVICE_EMAIL          = var.service_email
      TOKEN_SCOPES           = var.token_scopes
      WEBHOOK_SECRET         = var.webhook_secret
      GRAFANA_ADMIN_PASSWORD = var.grafana_admin_password
    }
  }
}
