#!/bin/bash
#
# mkcert でローカル CA とワイルドカード証明書を作り、Docker volume にだけ書く。
# 鍵をリポジトリやホストの作業ディレクトリに残さないため、一時ディレクトリで発行して消す。

set -euo pipefail

readonly WRITER_IMAGE="alpine:3.21"

# @description メッセージを stderr に出す。
# @arg $@ string メッセージ
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

# @description 必要な環境変数がそろっているか確認する。
# @exitcode 1 足りないものがある
check_env() {
  local name
  for name in DOMAIN CERTS_VOLUME INSTALL_CA; do
    if [[ -z "${!name:-}" ]]; then
      err "環境変数 ${name} が未設定です"
      return 1
    fi
  done
}

# @description ファイルを 1 つ volume に書く。中身は stdin で渡し、引数には出さない。
# @arg $1 string volume 内のファイル名
# @arg $2 string パーミッション（例 0644）
write_file() {
  local name="$1"
  local mode="$2"
  docker run --rm -i -v "${CERTS_VOLUME}:/c" -e NAME="${name}" -e MODE="${mode}" "${WRITER_IMAGE}" \
    sh -c 'cat > "/c/${NAME}" && chmod "${MODE}" "/c/${NAME}"'
}

main() {
  local work
  check_env
  if [[ "${INSTALL_CA}" == "true" ]]; then
    # 既に登録済みなら何もしない。初回だけキーチェーンの確認が出る
    mkcert -install
  fi
  work="$(mktemp -d)"
  # main() を抜けると local work は失効するため、trap には値を今展開して渡す
  # shellcheck disable=SC2064
  trap "rm -rf '${work}'" EXIT
  (cd "${work}" && mkcert -cert-file cert.pem -key-file key.pem "*.${DOMAIN}" "${DOMAIN}")
  write_file cert.pem 0644 < "${work}/cert.pem"
  # Traefik は root で動くので鍵は 0600 でよい
  write_file key.pem 0600 < "${work}/key.pem"
}

main "$@"
