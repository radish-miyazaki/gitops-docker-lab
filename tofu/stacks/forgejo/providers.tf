# 認証は FORGEJO_USERNAME / FORGEJO_PASSWORD 環境変数で受ける。provider 設定は state に残らない（ADR 0009）
provider "forgejo" {
  host = data.terraform_remote_state.platform.outputs.forgejo_url_host
}
