#!/bin/bash
#
# forgejo → platform の順に destroy する。
# doco-cd が作った sample-app は OpenTofu 管理外なので、compose で別に消す。

set -euo pipefail

# SC2155 対策のため代入と readonly 化を分ける
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly ROOT
# shellcheck source=scripts/lib.sh
source "${ROOT}/scripts/lib.sh"

# @description 指定したスタックを destroy する。state が無ければ何もしない。
# @arg $1 string スタック名（platform か forgejo）
destroy_stack() {
  local stack="$1"
  (
    cd "${ROOT}/terraform/stacks/${stack}"
    [[ -f terraform.tfstate ]] || return 0
    tofu destroy -input=false -auto-approve
  )
}

# @description forgejo の destroy に要る情報が揃っているか確認する。
#   platform の state か lab-secrets volume が先に消えていると
#   export_forgejo_env が読む forgejo_admin_username / forgejo_admin_password が取れない。
# @exitcode 0 揃っている
# @exitcode 1 欠けている
can_destroy_forgejo() {
  [[ -f "${ROOT}/terraform/stacks/platform/terraform.tfstate" ]] || return 1
  (cd "${ROOT}/terraform/stacks/platform" && tofu output -raw forgejo_admin_username) >/dev/null 2>&1 \
    && read_secret forgejo_admin_password >/dev/null 2>&1
}

main() {
  if [[ -f "${ROOT}/terraform/stacks/forgejo/terraform.tfstate" ]]; then
    if can_destroy_forgejo; then
      export_forgejo_env
      destroy_stack forgejo
    else
      err "terraform/stacks/platform の state か lab-secrets volume が無く、forgejo 認証情報が読めません。forgejo の state が孤立しているので destroy をスキップします。terraform/stacks/forgejo で手動確認してください"
    fi
  fi

  # 存在しない project を down してもエラーにはならないが、
  # 動いているコンテナが無ければ down 自体を呼ばない
  if [[ -n "$(docker compose -p sample-app ps -q)" ]]; then
    docker compose -p sample-app down --remove-orphans
  fi

  destroy_stack platform
}

main "$@"
