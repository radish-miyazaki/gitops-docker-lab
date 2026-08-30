output "id" {
  description = "bootstrap 完了を待つための依存用 ID"
  value       = terraform_data.this.id
}

output "admin_username" {
  description = "Forgejo 管理者のユーザー名"
  value       = var.admin_username
}

output "service_username" {
  description = "doco-cd が Git 認証に使うユーザー名"
  value       = var.service_username
}
