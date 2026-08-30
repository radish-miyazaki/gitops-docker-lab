#!/bin/bash
#
# 各スクリプトが source で読み込む共通処理。単独では実行しない。
# 読み込む側は ROOT（リポのルート）を先に定義しておく。

# 2 回 source されても readonly の再代入で落ちないようにする
: "${SECRETS_VOLUME:=lab-secrets}"
readonly SECRETS_VOLUME
: "${SECRETS_READER_IMAGE:=alpine:3.21}"
readonly SECRETS_READER_IMAGE

# @description メッセージを stderr に出す。
# @arg $@ string メッセージ
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

# @description 標準ソケットが無い環境（OrbStack など）でだけ docker context から DOCKER_HOST を導く。
#   Docker Desktop は /var/run/docker.sock を持つので何もしない。
# @set DOCKER_HOST string Docker デーモンの接続先
export_docker_host() {
  if [[ -n "${DOCKER_HOST:-}" || -S /var/run/docker.sock ]]; then
    return 0
  fi
  DOCKER_HOST="$(docker context inspect --format '{{(index .Endpoints "docker").Host}}')"
  export DOCKER_HOST
}

# bootstrap.sh / destroy.sh など、このファイルを source する側は
# 以降の docker / tofu 呼び出しで DOCKER_HOST が解決済みであることを前提にできる
export_docker_host

# @description volume から秘匿値を 1 つ読む。ホストのファイルには落とさない。
# @arg $1 string ファイル名（forgejo_admin_password など）
# @stdout 秘匿値
read_secret() {
  local name="$1"
  docker run --rm -v "${SECRETS_VOLUME}:/s" "${SECRETS_READER_IMAGE}" cat "/s/${name}"
}

# @description forgejo スタックの provider 認証と Webhook secret を環境変数で渡す（ADR 0009）。
# @set FORGEJO_USERNAME string Forgejo 管理者名
# @set FORGEJO_PASSWORD string Forgejo 管理者パスワード
# @set TF_VAR_webhook_secret string Webhook secret
export_forgejo_env() {
  FORGEJO_USERNAME="$(cd "${ROOT}/terraform/stacks/platform" \
    && tofu output -raw forgejo_admin_username)"
  FORGEJO_PASSWORD="$(read_secret forgejo_admin_password)"
  TF_VAR_webhook_secret="$(read_secret webhook_secret)"
  export FORGEJO_USERNAME FORGEJO_PASSWORD TF_VAR_webhook_secret
}
