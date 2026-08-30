resource "terraform_data" "this" {
  # volume を作り直したら証明書も書き直す
  triggers_replace = [var.certs_volume_name, var.domain]

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
