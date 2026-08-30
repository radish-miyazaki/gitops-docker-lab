#!/bin/bash
#
# sample-app/ の内容を Forgejo のリポに初回 push する。
# パスワードは GIT_ASKPASS 経由で渡し、URL や引数に含めない。

set -euo pipefail

# SC2155 対策のため代入と readonly 化を分ける
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly ROOT
# shellcheck source=scripts/lib.sh
source "${ROOT}/scripts/lib.sh"

# @description git が認証を求めたときだけ volume から読む askpass スクリプトを作る。
# @arg $1 string 出力先パス
# @arg $2 string ユーザー名
write_askpass() {
  local path="$1"
  local user="$2"
  cat > "${path}" <<EOF
#!/bin/bash
case "\$1" in
  *sername*) echo "${user}" ;;
  *) docker run --rm -v "${SECRETS_VOLUME}:/s" "${SECRETS_READER_IMAGE}" cat /s/forgejo_admin_password ;;
esac
EOF
  chmod +x "${path}"
}

main() {
  local clone_url admin_user work
  clone_url="$(cd "${ROOT}/tofu/stacks/forgejo" && tofu output -raw sample_app_clone_url_host)"
  admin_user="$(cd "${ROOT}/tofu/stacks/platform" && tofu output -raw forgejo_admin_username)"

  work="$(mktemp -d)"
  # main() を抜けると local work は失効するため、trap には値を今展開して渡す
  # shellcheck disable=SC2064
  trap "rm -rf '${work}'" EXIT
  write_askpass "${work}/askpass.sh" "${admin_user}"

  cp -R "${ROOT}/sample-app/." "${work}/repo"
  cd "${work}/repo"
  # README はこのリポの読者向けなので push しない
  rm -f README.md
  git init -q -b main
  git -c user.name=seed -c user.email=seed@localhost.invalid add .
  git -c user.name=seed -c user.email=seed@localhost.invalid commit -q -m "feat: sample-app の初版"
  GIT_ASKPASS="${work}/askpass.sh" GIT_TERMINAL_PROMPT=0 git push -q "${clone_url}" main:main

  echo "push しました: ${clone_url}"
}

main "$@"
