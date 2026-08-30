#!/bin/bash
#
# OpenTofu と YAML と Markdown とシェルの lint、秘匿値の混入検査をまとめて実行する。

set -euo pipefail
shopt -s nullglob

# SC2155 対策のため代入と readonly 化を分ける
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly ROOT

# @description OpenTofu の fmt と validate と tflint を実行する。
#   modules も validate の対象にするため、backend 無しで init する。
#   tofu/ がまだ存在しない段階では何もせず成功として抜ける。
# @exitcode 0 すべて通った
# @exitcode 1 いずれかが失敗した
lint_terraform() {
  local dir
  [[ -d "${ROOT}/tofu" ]] || return 0
  tofu fmt -check -recursive "${ROOT}/tofu"
  for dir in "${ROOT}"/tofu/stacks/* "${ROOT}"/tofu/modules/*; do
    [[ -d "${dir}" ]] || continue
    (cd "${dir}" \
      && tofu init -backend=false -input=false >/dev/null \
      && tofu validate)
  done
  # --recursive と --chdir は併用できないので cd する
  (cd "${ROOT}/tofu" && tflint --recursive --config "${ROOT}/.tflint.hcl")
}

# @description YAML と Markdown とシェルスクリプトを lint する。
lint_text() {
  ryl "${ROOT}"
  rumdl check "${ROOT}"
  shellcheck "${ROOT}"/scripts/*.sh "${ROOT}"/tofu/modules/*/*.sh
}

# @description 秘匿値がコミット対象に混ざっていないか検査する。
lint_secrets() {
  gitleaks detect --source "${ROOT}" --no-banner --redact
}

main() {
  lint_terraform
  lint_text
  lint_secrets
}

main "$@"
