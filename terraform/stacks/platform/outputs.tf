output "forgejo_url_internal" {
  description = "コンテナ間で使う Forgejo の URL"
  value       = local.forgejo_url_internal
}

output "forgejo_url_host" {
  description = "ホストから使う Forgejo の URL"
  value       = local.forgejo_url_host
}

output "forgejo_admin_username" {
  description = "Forgejo 管理者のユーザー名"
  value       = module.forgejo_bootstrap.admin_username
}

output "doco_cd_username" {
  description = "doco-cd が Git 認証に使うユーザー名"
  value       = module.forgejo_bootstrap.service_username
}

output "doco_cd_webhook_url" {
  description = "Forgejo の Webhook に登録する URL"
  value       = "http://doco-cd:${local.doco_cd_http_port}/v1/webhook"
}

output "secrets_volume_name" {
  description = "秘匿値を置いた Docker volume 名"
  value       = docker_volume.secrets.name
}

output "org_name" {
  description = "Forgejo 上の組織名"
  value       = var.org_name
}

output "sample_app_repo_name" {
  description = "デプロイ対象リポ名"
  value       = var.sample_app_repo_name
}

output "domain" {
  description = "ラボのドメイン"
  value       = var.domain
}

output "urls" {
  description = "各サービスの URL"
  value       = local.urls
}
