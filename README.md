# gitops-docker-lab

Docker Compose だけで GitOps を体験するための学習環境。Git に push すると doco-cd がデプロイ先を宣言どおりに揃える。

## 構成

- Traefik: リバースプロキシ。ホストに出すポートは 80 / 443 だけで、各サービスには名前で届く
- Forgejo: Git サーバー (<https://forgejo.gitops.localhost>)
- doco-cd: GitOps ツール。Webhook とポーリングで変更を拾い `docker compose up` する (<https://doco-cd.gitops.localhost>)
- Prometheus / Grafana: doco-cd のメトリクスを可視化 (<https://prometheus.gitops.localhost> / <https://grafana.gitops.localhost>)
- sample-app: デプロイ対象の Caddy (<https://app.gitops.localhost>)

すべて OpenTofu で作る。ツールは mise で入れる。

## GitOps の流れ

1. `gitops-lab/sample-app` に push する
2. Forgejo が Webhook で doco-cd に通知する。5 分ごとのポーリングも動いていて、Webhook が落ちても拾う
3. doco-cd がリポを clone し、`.doco-cd.yaml` に従って `docker compose up` する
4. Grafana の doco-cd ダッシュボードにデプロイ回数が出る

## 構成図

```text
ホスト
├─ mise: opentofu / tflint / terraform-docs / prek / ryl / rumdl / gitleaks / shellcheck / mkcert
└─ Docker network: gitops-lab
   ├─ traefik      ホスト :80 / :443 のみ公開。ラベルを見て下の各サービスに振り分ける
   │  ├─ forgejo.gitops.localhost      Git サーバー
   │  ├─ doco-cd.gitops.localhost      Webhook 受信 / :9120 metrics（metrics は内部のみ）
   │  ├─ prometheus.gitops.localhost
   │  ├─ grafana.gitops.localhost
   │  └─ app.gitops.localhost          doco-cd がデプロイする Caddy（compose service web）
   ├─ volume lab-secrets  秘匿値の唯一の保存先
   └─ volume lab-certs    mkcert が発行した証明書と鍵の唯一の保存先
```

## OpenTofu の構成

- `terraform/stacks/platform`: コンテナ群と volume（docker provider）
- `terraform/stacks/forgejo`: Forgejo 内の組織とリポと Webhook（forgejo provider）
- `terraform/modules/`: 上の 2 つが使う部品

順序と依存は `terraform/stacks/README.md`。

## 前提

- Docker が動いていること（Docker Desktop / OrbStack）
- mise が入っていること

## 使い方

```sh
mise install
mise run bootstrap   # platform → forgejo の順に apply し、sample-app を Forgejo に push する
mise run creds       # 各種パスワードを表示する
mise run demo        # 変更を push して反映を見る手順を表示する
mise run destroy     # すべて消す
```

Forgejo へのログインはユーザー名 `lab-admin`、パスワードは `mise run creds` で表示する。URL は `mise run bootstrap` の最後に表示する。

初回の `mise run bootstrap` では mkcert がローカル CA を OS の信頼ストアに登録するため、管理者確認が 1 度だけ出る（[ADR 0011](docs/adr/0011-traefik-https.md)）。

## 開発

```sh
mise run lint   # fmt / validate / tflint / ryl / rumdl / gitleaks / shellcheck
mise run docs   # terraform-docs で README を更新する
```

各 hook の定義は `prek.toml`、YAML の検査ルールは `.ryl.toml` にある。

コミットは Conventional Commits。prek が commit-msg で検査する。

push と PR のたびに GitHub Actions が `mise run lint` を実行する（[ADR 0012](docs/adr/0012-ci-github-actions.md)）。Action は SHA で固定している。

## 秘匿情報

このリポは public 公開を前提にしている。パスワードやトークンは apply 時に生成し、Docker volume `lab-secrets` にだけ書く。詳細は [ADR 0006](docs/adr/0006-no-secrets-in-repo.md) と [ADR 0009](docs/adr/0009-secrets-via-ephemeral-and-volume.md)。

## 既知の制約

- forgejo provider に write-only 引数がないため、Webhook secret は `terraform/stacks/forgejo/terraform.tfstate` に残る。state はコミットしない
- Forgejo の `webhook.ALLOWED_HOST_LIST=private` はローカル前提の緩い設定
- Forgejo は管理者ユーザー名に `admin` を使えない（予約語として拒否する）ため、`lab-admin` を使う
- `DOCKER_HOST` は `scripts/lib.sh` が docker context から補う。OrbStack でも Docker Desktop でも動く
- ホストの 80 / 443 を Traefik が使う。他のサーバーが掴んでいると `mise run bootstrap` が失敗する
- 証明書は mkcert のローカル CA で署名しているので、この Mac 以外からは信頼されない
- mkcert のローカル CA を OS の信頼ストアから外したいときは `mkcert -uninstall` を使う

## ドキュメント

- 意思決定の記録: `docs/adr/`
