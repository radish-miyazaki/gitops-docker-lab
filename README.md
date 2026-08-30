# gitops-docker-lab

Docker Compose だけで GitOps を体験するための学習環境。Git に push すると doco-cd がデプロイ先を宣言どおりに揃える。

## 構成

- Forgejo: Git サーバー (<http://localhost:3000>)
- doco-cd: GitOps ツール。Webhook とポーリングで変更を拾い `docker compose up` する
- Prometheus / Grafana: doco-cd のメトリクスを可視化 (<http://localhost:3001>)
- sample-app: デプロイ対象の nginx (<http://localhost:8000>)

すべて OpenTofu で作る。ツールは mise で入れる。

## 前提

- Docker Desktop が動いていること
- mise が入っていること

## 使い方

```sh
mise install
mise run bootstrap   # platform → forgejo の順に apply し、sample-app を Forgejo に push する
mise run creds       # 各種パスワードを表示する
mise run demo        # 変更を push して反映を見る手順を表示する
mise run destroy     # すべて消す
```

## 秘匿情報

このリポは public 公開を前提にしている。パスワードやトークンは apply 時に生成し、Docker volume `lab-secrets` にだけ書く。詳細は [ADR 0006](docs/adr/0006-no-secrets-in-repo.md) と [ADR 0009](docs/adr/0009-secrets-via-ephemeral-and-volume.md)。

## ドキュメント

- 意思決定の記録: `docs/adr/`
