#!/bin/bash
#
# Forgejo の初期ユーザーとトークンを作り、秘匿値を Docker volume に書く。
# 値は環境変数で受け取り、コマンド引数には出さない（ps に見えるのを避ける）。

set -euo pipefail

readonly HEALTH_TIMEOUT_SEC=60
readonly WRITER_IMAGE="alpine:3.21"

# @description メッセージを stderr に出す。
# @arg $@ string メッセージ
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

# @description 必要な環境変数がそろっているか確認する。
# @exitcode 0 そろっている
# @exitcode 1 足りないものがある
check_env() {
  local name
  for name in CONTAINER FORGEJO_PORT SECRETS_VOLUME ADMIN_USERNAME ADMIN_EMAIL ADMIN_PASSWORD \
      SERVICE_USERNAME SERVICE_EMAIL TOKEN_SCOPES WEBHOOK_SECRET GRAFANA_ADMIN_PASSWORD; do
    if [[ -z "${!name:-}" ]]; then
      err "環境変数 ${name} が未設定です"
      return 1
    fi
  done
}

# @description Forgejo の API が応答するまで待つ。
#   起動直後は DB 初期化中で CLI が失敗するため。
# @exitcode 0 応答した
# @exitcode 1 HEALTH_TIMEOUT_SEC 秒以内に応答しなかった
wait_for_forgejo() {
  local i
  for ((i = 0; i < HEALTH_TIMEOUT_SEC; i++)); do
    if docker exec "${CONTAINER}" curl -sf "http://localhost:${FORGEJO_PORT}/api/healthz" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  err "forgejo が ${HEALTH_TIMEOUT_SEC} 秒以内に起動しませんでした"
  return 1
}

# @description Forgejo コンテナ内で forgejo CLI を実行する。
#   rootful イメージでは git ユーザーで実行しないと app.ini の権限が壊れる。
# @arg $@ string forgejo に渡す引数
# @stdout forgejo CLI の出力
forgejo_cli() {
  docker exec -u git "${CONTAINER}" forgejo "$@"
}

# @description 管理者と doco-cd 用ユーザーを作る。
#   admin のパスワードはホスト側の docker exec の argv に出すと ps に見えてしまうため、
#   環境変数のままコンテナへ転送し、コンテナ内の sh -c で展開する。
create_users() {
  # shellcheck disable=SC2016  # $1 $2 ADMIN_PASSWORD はコンテナ内の sh で展開させる
  docker exec -u git -e ADMIN_PASSWORD "${CONTAINER}" sh -c '
    forgejo admin user create \
      --admin \
      --username "$1" \
      --email "$2" \
      --password "${ADMIN_PASSWORD}" \
      --must-change-password=false
  ' _ "${ADMIN_USERNAME}" "${ADMIN_EMAIL}"

  # doco-cd はトークンだけを使うので、パスワードは生成して捨てる
  forgejo_cli admin user create \
    --username "${SERVICE_USERNAME}" \
    --email "${SERVICE_EMAIL}" \
    --random-password \
    --must-change-password=false
}

# @description doco-cd 用ユーザーのアクセストークンを発行する。
# @stdout トークン文字列
generate_git_token() {
  forgejo_cli admin user generate-access-token \
    --username "${SERVICE_USERNAME}" \
    --token-name doco-cd \
    --scopes "${TOKEN_SCOPES}" \
    --raw
}

# @description 秘匿値を 1 つ volume に書く。
#   値を docker run の argv (-e VALUE=...) に出すと ps に見えてしまうため、標準入力で渡す。
#   umask 022 で書くので 0644 になり、uid 472 で読む Grafana からも読める。
#   volume 自体は docker 経由でしか触れない。
# @arg $1 string ファイル名
# @arg $2 string 値
write_secret() {
  local name="$1"
  local value="$2"
  printf '%s' "${value}" | docker run --rm -i -v "${SECRETS_VOLUME}:/s" -e NAME="${name}" \
    "${WRITER_IMAGE}" \
    sh -c 'umask 022; cat > "/s/${NAME}"'
}

main() {
  local git_token
  check_env
  wait_for_forgejo
  create_users
  git_token="$(generate_git_token)"

  write_secret forgejo_admin_password "${ADMIN_PASSWORD}"
  write_secret git_token "${git_token}"
  write_secret webhook_secret "${WEBHOOK_SECRET}"
  write_secret grafana_admin_password "${GRAFANA_ADMIN_PASSWORD}"
}

main "$@"
