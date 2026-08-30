variable "platform_state_path" {
  description = "platform スタックの tfstate のパス"
  type        = string
  default     = "../platform/terraform.tfstate"
}

variable "webhook_secret" {
  description = "Webhook の secret。lab-secrets/webhook_secret の値を TF_VAR_webhook_secret で渡す。forgejo provider に write-only 引数がないため state に残る"
  type        = string
  sensitive   = true
}
