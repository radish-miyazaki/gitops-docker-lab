# 0004. 基盤リポとアプリリポを分ける

- ステータス: 採用
- 日付: 2026-08-30

## 背景

GitOps ではデプロイ対象の宣言（Compose）を Git に置き、ツールがそれを pull する。基盤を作るコードと、デプロイ対象の宣言を同じリポに置くと、何が GitOps の「対象」なのかが見えにくい。

## 決定

このリポ（gitops-docker-lab）は基盤だけを持つ。
デプロイ対象の Compose は Forgejo 上の `gitops-lab/sample-app` に置き、初回だけ `scripts/seed-sample-app.sh` で `sample-app/` の内容を push する。
以降の変更は Forgejo 上のリポに直接 push する。

## 検討した選択肢

| 選択肢 | 良い点 | 悪い点 |
|---|---|---|
| 分離 | 実際の GitOps の形に近い | 初回 seed が要る |
| モノレポ | 1 つで済む | doco-cd がこのリポ全体を clone することになり、基盤と対象の境界が曖昧 |

## 影響

`sample-app/` は seed 用の雛形で、push 後は Forgejo 側が正になる。

## 参考

- 0001
