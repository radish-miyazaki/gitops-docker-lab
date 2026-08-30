#!/bin/bash
#
# platform → forgejo の順に apply し、sample-app を Forgejo に push する。

set -euo pipefail

# SC2155 対策のため代入と readonly 化を分ける
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly ROOT
# shellcheck source=scripts/lib.sh
source "${ROOT}/scripts/lib.sh"

# @description 指定したスタックを init して apply する。
# @arg $1 string スタック名（platform か forgejo）
apply_stack() {
  local stack="$1"
  (
    cd "${ROOT}/terraform/stacks/${stack}"
    tofu init -input=false
    tofu apply -input=false -auto-approve
  )
}

main() {
  local admin_user

  apply_stack platform
  export_forgejo_env
  apply_stack forgejo
  "${ROOT}/scripts/seed-sample-app.sh"

  admin_user="$(cd "${ROOT}/terraform/stacks/platform" && tofu output -raw forgejo_admin_username)"

  echo
  echo "Forgejo:  http://localhost:3000  (${admin_user} / mise run creds)"
  echo "Grafana:  http://localhost:3001"
  echo "sample:   http://localhost:8000"
}

main "$@"
