output "repository_id" {
  description = "リポ ID"
  value       = forgejo_repository.this.id
}

output "clone_url" {
  description = "HTTP の clone URL（ROOT_URL 基準）"
  value       = forgejo_repository.this.clone_url
}

output "html_url" {
  description = "ブラウザで開く URL"
  value       = forgejo_repository.this.html_url
}
