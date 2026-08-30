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

# @description tofu output -json urls の結果から 1 件取り出す。jq を増やしたくないので sed で拾う。
# @arg $1 string urls の JSON
# @arg $2 string キー（forgejo など）
# @stdout URL
url_from() {
  local json="$1"
  local key="$2"
  sed -n "s/.*\"${key}\": *\"\([^\"]*\)\".*/\\1/p" <<< "${json}"
}

main() {
  local admin_user urls

  apply_stack platform
  export_forgejo_env
  apply_stack forgejo
  "${ROOT}/scripts/seed-sample-app.sh"

  admin_user="$(cd "${ROOT}/terraform/stacks/platform" && tofu output -raw forgejo_admin_username)"
  urls="$(cd "${ROOT}/terraform/stacks/platform" && tofu output -json urls)"

  echo
  echo "Forgejo:    $(url_from "${urls}" forgejo)  (${admin_user} / mise run creds)"
  echo "Grafana:    $(url_from "${urls}" grafana)"
  echo "Prometheus: $(url_from "${urls}" prometheus)"
  echo "doco-cd:    $(url_from "${urls}" doco_cd)"
  echo "sample:     $(url_from "${urls}" app)"
}

main "$@"
