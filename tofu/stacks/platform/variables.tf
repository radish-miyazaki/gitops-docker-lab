variable "docker_host" {
  description = "Docker デーモンの接続先。null なら DOCKER_HOST 環境変数を使う"
  type        = string
  default     = null
}

variable "network_name" {
  description = "全コンテナが属する Docker ネットワーク名"
  type        = string
  default     = "gitops-lab"
}

variable "secrets_volume_name" {
  description = "秘匿値を置く Docker volume 名"
  type        = string
  default     = "lab-secrets"
}

variable "forgejo_image" {
  description = "Forgejo のイメージ"
  type        = string
  default     = "codeberg.org/forgejo/forgejo:16"
}

variable "doco_cd_image" {
  description = "doco-cd のイメージ"
  type        = string
  default     = "ghcr.io/kimdre/doco-cd:0.113.0"
}

variable "prometheus_image" {
  description = "Prometheus のイメージ"
  type        = string
  default     = "prom/prometheus:v3.5.0"
}

variable "grafana_image" {
  description = "Grafana のイメージ"
  type        = string
  default     = "grafana/grafana:12.1.1"
}

variable "forgejo_host_port" {
  description = "ホスト側で Forgejo を公開するポート"
  type        = number
  default     = 3000
}

variable "doco_cd_host_port" {
  description = "ホスト側で doco-cd の Webhook を公開するポート"
  type        = number
  default     = 8080
}

variable "prometheus_host_port" {
  description = "ホスト側で Prometheus を公開するポート"
  type        = number
  default     = 9090
}

variable "grafana_host_port" {
  description = "ホスト側で Grafana を公開するポート"
  type        = number
  default     = 3001
}

variable "org_name" {
  description = "Forgejo 上の組織名。forgejo スタックと doco-cd のポーリング設定で使う"
  type        = string
  default     = "gitops-lab"
}

variable "sample_app_repo_name" {
  description = "デプロイ対象リポ名"
  type        = string
  default     = "sample-app"
}

variable "poll_interval" {
  description = "doco-cd のポーリング間隔。Webhook の取りこぼしを拾う"
  type        = string
  default     = "5m"
}

variable "forgejo_admin_username" {
  description = "Forgejo 管理者のユーザー名。Forgejo は admin を予約語として拒否するため既定値は別名にしてある"
  type        = string
  default     = "lab-admin"
}
