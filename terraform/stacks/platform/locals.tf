locals {
  forgejo_internal_port    = 3000
  doco_cd_http_port        = 8080
  doco_cd_metrics_port     = 9120
  prometheus_internal_port = 9090
  grafana_internal_port    = 3000

  hosts = {
    forgejo    = "forgejo.${var.domain}"
    grafana    = "grafana.${var.domain}"
    prometheus = "prometheus.${var.domain}"
    doco_cd    = "doco-cd.${var.domain}"
    app        = "app.${var.domain}"
  }
  urls = { for k, h in local.hosts : k => "https://${h}/" }

  forgejo_url_host     = local.urls.forgejo
  forgejo_url_internal = "http://forgejo:${local.forgejo_internal_port}/"

  sample_app_clone_url_internal = "${local.forgejo_url_internal}${var.org_name}/${var.sample_app_repo_name}.git"

  # コンテナ内で秘匿値を読む場所。lab-secrets をここにマウントする
  secrets_mount_path = "/run/secrets"
  # Traefik が証明書を読む場所。lab-certs をここにマウントする
  certs_mount_path = "/certs"
}

# ルーティングのラベルはサービスごとに同じ形になるので、まとめて組み立てる
# app は hosts / urls には含めるが、そのルーターは sample-app/compose.yaml 側で定義している。
# そのため traefik_labels.app はどこからも参照されないが、意図した状態
locals {
  traefik_labels = { for k, h in local.hosts : k => {
    "traefik.enable"                        = "true"
    "traefik.http.routers.${k}.rule"        = "Host(`${h}`)"
    "traefik.http.routers.${k}.entrypoints" = "websecure"
    "traefik.http.routers.${k}.tls"         = "true"
  } }
}
