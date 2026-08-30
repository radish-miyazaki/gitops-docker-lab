resource "terraform_data" "this" {
  # volume を作り直すと中身が空になるので証明書も発行し直す。
  # 名前は destroy/apply で変わらないため、作り直しの検出には ID を使う
  triggers_replace = [var.certs_volume_id, var.domain]

  provisioner "local-exec" {
    command     = "${path.module}/issue-cert.sh"
    interpreter = ["bash"]
    environment = {
      DOMAIN       = var.domain
      CERTS_VOLUME = var.certs_volume_name
      INSTALL_CA   = var.install_ca ? "true" : "false"
    }
  }
}
