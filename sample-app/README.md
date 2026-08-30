# sample-app

doco-cd のデプロイ対象。`scripts/seed-sample-app.sh` が Forgejo の `gitops-lab/sample-app` に初回 push する。push 後は Forgejo 側が正で、このディレクトリは雛形にすぎない。

配信は Caddy（`caddy:2-alpine`）。ポートは公開せず、`compose.yaml` の Traefik ラベルで `https://app.gitops.localhost` に振り分ける。TLS は Traefik 側で終端するので Caddy 自体は `:80` で平文のまま待つ。

変更を試すときは Forgejo から clone して `html/index.html` の版数を上げ、push する。
