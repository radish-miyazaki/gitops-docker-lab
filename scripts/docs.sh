#!/bin/bash
#
# terraform-docs で各 root module と module の README を更新する。

set -euo pipefail

# SC2155 対策のため代入と readonly 化を分ける
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly ROOT

main() {
  local dir
  for dir in "${ROOT}"/tofu/stacks/* "${ROOT}"/tofu/modules/*; do
    [[ -d "${dir}" ]] || continue
    terraform-docs "${dir}"
  done
}

main "$@"
