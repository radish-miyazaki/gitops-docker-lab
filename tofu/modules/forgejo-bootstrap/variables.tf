variable "container_name" {
  description = "Forgejo コンテナ名。docker exec の対象"
  type        = string
}

variable "forgejo_container_id" {
  description = "Forgejo コンテナの ID。triggers_replace 用で、コンテナが作り直されたことの検出にだけ使う"
  type        = string
}

variable "secrets_volume_name" {
  description = "秘匿値を書く Docker volume 名"
  type        = string
}

variable "forgejo_data_volume_id" {
  description = "Forgejo のデータ volume の ID。triggers_replace 用で、volume が作り直されたことの検出にだけ使う"
  type        = string
}

variable "forgejo_port" {
  description = "Forgejo コンテナ内の HTTP ポート"
  type        = number
  default     = 3000
}

variable "admin_username" {
  description = "Forgejo 管理者のユーザー名。Forgejo は admin を予約語として拒否するため既定値は別名にしてある"
  type        = string
  default     = "lab-admin"
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
