#!/bin/bash
#
# terraform-docs で各 root module と module の README を更新する。

set -euo pipefail
shopt -s nullglob

# SC2155 対策のため代入と readonly 化を分ける
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly ROOT

main() {
  local dir
  for dir in "${ROOT}"/terraform/stacks/* "${ROOT}"/terraform/modules/*; do
    [[ -d "${dir}" ]] || continue
    # cwd に依存せず設定ファイルを解決させるため明示的にパスを渡す
    terraform-docs --config "${ROOT}/.terraform-docs.yml" "${dir}"
  done
}

main "$@"
