#!/bin/bash
#
# lab-secrets の内容を表示する。

set -euo pipefail

# SC2155 対策のため代入と readonly 化を分ける
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly ROOT
# shellcheck source=scripts/lib.sh
source "${ROOT}/scripts/lib.sh"

main() {
  local name
  for name in forgejo_admin_password grafana_admin_password webhook_secret git_token; do
    printf '%-24s %s\n' "${name}" "$(read_secret "${name}")"
  done
}

main "$@"
