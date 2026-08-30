variable "container_name" {
  description = "Forgejo コンテナ名。docker exec の対象"
  type        = string
}

variable "secrets_volume_name" {
  description = "秘匿値を書く Docker volume 名"
  type        = string
}

variable "admin_username" {
  description = "Forgejo 管理者のユーザー名"
  type        = string
  default     = "admin"
}

variable "admin_email" {
  description = "Forgejo 管理者のメールアドレス。ローカル用のダミーでよい"
  type        = string
  default     = "admin@localhost.invalid"
}

variable "admin_password" {
  description = "Forgejo 管理者のパスワード。ephemeral な値を渡す"
  type        = string
  ephemeral   = true
}

variable "service_username" {
  description = "doco-cd が Git 認証に使うユーザー名"
  type        = string
  default     = "doco-cd"
}

variable "service_email" {
  description = "doco-cd ユーザーのメールアドレス"
  type        = string
  default     = "doco-cd@localhost.invalid"
}

variable "token_scopes" {
  description = "doco-cd ユーザーのトークンに付けるスコープ"
  type        = string
  default     = "read:repository"
}

variable "webhook_secret" {
  description = "Webhook の secret。ephemeral な値を渡す"
  type        = string
  ephemeral   = true
}

variable "grafana_admin_password" {
  description = "Grafana 管理者のパスワード。ephemeral な値を渡す"
  type        = string
  ephemeral   = true
}
