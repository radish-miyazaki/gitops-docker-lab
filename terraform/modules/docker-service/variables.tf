variable "name" {
  description = "コンテナ名。ネットワーク内のホスト名にもなる"
  type        = string
}

variable "image" {
  description = "docker_image の image_id か、タグ付きイメージ名"
  type        = string
}

variable "network_name" {
  description = "接続する Docker ネットワーク名"
  type        = string
}

variable "ports" {
  description = "公開ポート。external を省くとホストに公開しない"
  type = list(object({
    internal = number
    external = optional(number)
  }))
  default = []
}

variable "env" {
  description = "環境変数。KEY=VALUE 形式。秘匿値は渡さない（tfstate に残るため）"
  type        = list(string)
  default     = []
}

variable "volumes" {
  description = "名前付き volume のマウント"
  type = list(object({
    volume_name    = string
    container_path = string
    read_only      = optional(bool, false)
  }))
  default = []
}

variable "binds" {
  description = "ホストパスのバインドマウント。docker.sock のような特殊用途だけに使う"
  type = list(object({
    host_path      = string
    container_path = string
    read_only      = optional(bool, false)
  }))
  default = []
}

variable "uploads" {
  description = "コンテナ内パス => ファイル内容。設定ファイルの注入に使う。秘匿値は渡さない"
  type        = map(string)
  default     = {}
}

variable "user" {
  description = "実行ユーザー。null ならイメージの既定"
  type        = string
  default     = null
}

variable "healthcheck" {
  description = "ヘルスチェック。null なら設定しない"
  type = object({
    test         = list(string)
    interval     = optional(string, "10s")
    timeout      = optional(string, "5s")
    retries      = optional(number, 5)
    start_period = optional(string, "10s")
  })
  default = null
}

variable "wait_for_healthy" {
  description = "true なら healthcheck が通るまで create を待つ"
  type        = bool
  default     = false
}

variable "labels" {
  description = "コンテナのラベル。Traefik のルーティング定義に使う"
  type        = map(string)
  default     = {}
}
