locals {
  forgejo_internal_port = 3000
  doco_cd_http_port     = 8080
  doco_cd_metrics_port  = 9120

  forgejo_url_host     = "http://localhost:${var.forgejo_host_port}/"
  forgejo_url_internal = "http://forgejo:${local.forgejo_internal_port}/"

  sample_app_clone_url_internal = "${local.forgejo_url_internal}${var.org_name}/${var.sample_app_repo_name}.git"

  # コンテナ内で秘匿値を読む場所。lab-secrets をここにマウントする
  secrets_mount_path = "/run/secrets"
}
