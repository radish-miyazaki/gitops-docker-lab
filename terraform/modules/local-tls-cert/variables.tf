variable "domain" {
  description = "証明書を発行するドメイン。ワイルドカードと apex の両方を SAN に入れる"
  type        = string
}

variable "certs_volume_name" {
  description = "証明書と鍵を書く Docker volume 名"
  type        = string
}

variable "install_ca" {
  description = "mkcert -install でローカル CA を OS の信頼ストアに登録するか。初回は管理者確認が出る"
  type        = bool
  default     = true
}
