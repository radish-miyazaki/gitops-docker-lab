variable "owner" {
  description = "リポの所有者（組織名）"
  type        = string
}

variable "name" {
  description = "リポ名"
  type        = string
}

variable "description" {
  description = "リポの説明"
  type        = string
  default     = ""
}

variable "webhook_url" {
  description = "push を通知する URL"
  type        = string
}

variable "webhook_secret" {
  description = "Webhook の署名に使う secret。forgejo provider に write-only 引数がないため state に残る"
  type        = string
  sensitive   = true
}

variable "collaborator_username" {
  description = "read 権限で加えるユーザー名（doco-cd）"
  type        = string
}
