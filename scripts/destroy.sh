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
    cd "${ROOT}/tofu/stacks/${stack}"
    [[ -f terraform.tfstate ]] || return 0
    tofu destroy -input=false -auto-approve
  )
}

main() {
  if [[ -f "${ROOT}/tofu/stacks/forgejo/terraform.tfstate" ]]; then
    export_forgejo_env
    destroy_stack forgejo
  fi
  docker compose -p sample-app down --remove-orphans 2>/dev/null || true
  destroy_stack platform
}

main "$@"
