# gitops-docker-lab

Docker Compose だけで GitOps を体験するための学習環境。Git に push すると doco-cd がデプロイ先を宣言どおりに揃える。

## 構成

- Forgejo: Git サーバー (<http://localhost:3000>)
- doco-cd: GitOps ツール。Webhook とポーリングで変更を拾い `docker compose up` する
- Prometheus / Grafana: doco-cd のメトリクスを可視化 (<http://localhost:3001>)
- sample-app: デプロイ対象の nginx (<http://localhost:8000>)

すべて OpenTofu で作る。ツールは mise で入れる。

## GitOps の流れ

1. `gitops-lab/sample-app` に push する
2. Forgejo が Webhook で doco-cd に通知する。5 分ごとのポーリングも動いていて、Webhook が落ちても拾う
3. doco-cd がリポを clone し、`.doco-cd.yaml` に従って `docker compose up` する
4. Grafana の doco-cd ダッシュボードにデプロイ回数が出る

## 構成図

```text
ホスト
├─ mise: opentofu / tflint / terraform-docs / prek / ryl / rumdl / gitleaks / shellcheck
└─ Docker network: gitops-lab
   ├─ forgejo      :3000  Git サーバー
   ├─ doco-cd      :8080  Webhook 受信 / :9120 metrics
   ├─ prometheus   :9090
   ├─ grafana      :3001
   ├─ sample-app-web-1  :8000  doco-cd がデプロイする nginx（compose service web）
   └─ volume lab-secrets  秘匿値の唯一の保存先
```

## OpenTofu の構成

- `tofu/stacks/platform`: コンテナ群と volume（docker provider）
- `tofu/stacks/forgejo`: Forgejo 内の組織とリポと Webhook（forgejo provider）
- `tofu/modules/`: 上の 2 つが使う部品

順序と依存は `tofu/stacks/README.md`。

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

Forgejo へのログインはユーザー名 `lab-admin`、パスワードは `mise run creds` で表示する。

## 開発

```sh
mise run lint   # fmt / validate / tflint / ryl / rumdl / gitleaks / shellcheck
mise run docs   # terraform-docs で README を更新する
```

コミットは Conventional Commits。prek が commit-msg で検査する。

## 秘匿情報

このリポは public 公開を前提にしている。パスワードやトークンは apply 時に生成し、Docker volume `lab-secrets` にだけ書く。詳細は [ADR 0006](docs/adr/0006-no-secrets-in-repo.md) と [ADR 0009](docs/adr/0009-secrets-via-ephemeral-and-volume.md)。

## 既知の制約

- forgejo provider に write-only 引数がないため、Webhook secret は `tofu/stacks/forgejo/terraform.tfstate` に残る。state はコミットしない
- Forgejo の `webhook.ALLOWED_HOST_LIST=private` はローカル前提の緩い設定
- Forgejo は管理者ユーザー名に `admin` を使えない（予約語として拒否する）ため、`lab-admin` を使う
- `DOCKER_HOST` は `scripts/lib.sh` が docker context から補う。OrbStack でも Docker Desktop でも動く

## ドキュメント

- 意思決定の記録: `docs/adr/`
