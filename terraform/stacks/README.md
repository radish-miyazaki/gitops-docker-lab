# stacks

root module はここにだけ置く。apply の順序は次のとおりで、`mise run bootstrap` が担う。

1. `platform`: Docker 上にコンテナ群（Traefik を含む）と `lab-secrets` / `lab-certs` volume を作る
2. `forgejo`: platform の state を読み、Forgejo 内の組織とリポと Webhook を作る

依存は一方向。forgejo → platform の受け渡しは無い（ADR 0003、0008）。
