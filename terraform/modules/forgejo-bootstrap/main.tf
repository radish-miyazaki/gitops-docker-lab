# 旧名 bootstrap から改名した。state の実体は同じなので moved で引き継ぐ
moved {
  from = terraform_data.bootstrap
  to   = terraform_data.this
}

resource "terraform_data" "this" {
  # コンテナか volume を作り直したら Forgejo のデータも消えているので、やり直す。
  # 名前は destroy/apply で変わらないため、作り直しの検出には ID を使う
  triggers_replace = [var.forgejo_container_id, var.forgejo_data_volume_id]

  provisioner "local-exec" {
    command     = "${path.module}/bootstrap.sh"
    interpreter = ["bash"]
    environment = {
      CONTAINER              = var.container_name
      FORGEJO_PORT           = var.forgejo_port
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
