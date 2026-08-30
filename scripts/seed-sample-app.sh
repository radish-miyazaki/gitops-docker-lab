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

# @description リモートに main ブランチがすでにあるか調べる。
#   bootstrap を seed 済み環境に再実行したときに、fresh な root commit を push して
#   non-fast-forward で失敗するのを避けるための事前チェック。
# @arg $1 string リモート URL
# @arg $2 string askpass スクリプトのパス
# @exitcode 0 main ブランチがある
# @exitcode 1 まだ無い
remote_has_main() {
  local remote="$1"
  local askpass="$2"
  GIT_ASKPASS="${askpass}" GIT_TERMINAL_PROMPT=0 \
    git ls-remote --exit-code --heads "${remote}" main >/dev/null 2>&1
}

# @description git push をリトライ付きで実行する。
#   push が失敗する理由の切り分けはしておらず、どんな失敗でも同じだけ間を置いて再試行する。
#   動機になったのは、組織/リポジトリ作成直後は API 認証（tofu の forgejo provider）は
#   通っても git smart HTTP の basic 認証が数秒遅れて有効になることがある、という事例。
# @arg $1 string リモート URL
# @arg $2 string askpass スクリプトのパス
push_with_retry() {
  local remote="$1"
  local askpass="$2"
  local attempt
  for attempt in 1 2 3 4 5; do
    if GIT_ASKPASS="${askpass}" GIT_TERMINAL_PROMPT=0 git push -q "${remote}" main:main; then
      return 0
    fi
    err "git push に失敗しました（${attempt}/5 回目）。3 秒後に再試行します"
    sleep 3
  done
  err "git push が 5 回とも失敗しました"
  return 1
}

main() {
  local clone_url admin_user work
  clone_url="$(cd "${ROOT}/terraform/stacks/forgejo" && tofu output -raw sample_app_clone_url_host)"
  admin_user="$(cd "${ROOT}/terraform/stacks/platform" && tofu output -raw forgejo_admin_username)"

  work="$(mktemp -d)"
  # main() を抜けると local work は失効するため、trap には値を今展開して渡す
  # shellcheck disable=SC2064
  trap "rm -rf '${work}'" EXIT
  write_askpass "${work}/askpass.sh" "${admin_user}"

  if remote_has_main "${clone_url}" "${work}/askpass.sh"; then
    echo "すでに push 済みです: ${clone_url}"
    return 0
  fi

  cp -R "${ROOT}/sample-app/." "${work}/repo"
  cd "${work}/repo"
  # README はこのリポの読者向けなので push しない
  rm -f README.md
  git init -q -b main
  git -c user.name=seed -c user.email=seed@localhost.invalid add .
  git -c user.name=seed -c user.email=seed@localhost.invalid commit -q -m "feat: sample-app の初版"
  push_with_retry "${clone_url}" "${work}/askpass.sh"

  echo "push しました: ${clone_url}"
}

main "$@"
