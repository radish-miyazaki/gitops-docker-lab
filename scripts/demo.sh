#!/bin/bash
#
# 変更を push して反映を見る手順を表示する。体験の中心なので自動では push しない。
# ユーザー名は admin username が admin 固定ではない環境向けに tofu output から取る。

set -euo pipefail

# SC2155 対策のため代入と readonly 化を分ける
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly ROOT

main() {
  local admin_user
  admin_user="$(cd "${ROOT}/terraform/stacks/platform" && tofu output -raw forgejo_admin_username)"

  cat <<USAGE
1. clone する（ユーザー名は ${admin_user}、パスワードは mise run creds の forgejo_admin_password）
   git clone http://localhost:3000/gitops-lab/sample-app.git /tmp/sample-app && cd /tmp/sample-app
2. html/index.html の "v1" を "v2" に変えて push する
   git commit -am "feat: v2" && git push
3. 数秒後に反映を確認する
   curl -s http://localhost:8000 | grep -o 'sample-app v[0-9]*'
4. Grafana でデプロイ回数が増えたことを見る
   open http://localhost:3001/d/doco-cd
5. Webhook を止めてポーリングだけで反映されることも試す
   Forgejo の Settings > Webhooks で無効化し、v3 を push。5 分以内に反映される
USAGE
}

main "$@"
