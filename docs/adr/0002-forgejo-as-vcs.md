# 0002. VCS に Forgejo を使う

- ステータス: 採用
- 日付: 2026-08-30

## 背景

ローカルで完結する Git サーバーが要る。Webhook と API と OpenTofu provider があるものを選びたい。

## 決定

Forgejo をコンテナ 1 つ、SQLite で動かす。リポと Webhook は svalabs/forgejo provider で作る。

## 検討した選択肢

| 選択肢 | 良い点 | 悪い点 |
|---|---|---|
| Forgejo | 単一コンテナ。Webhook と API あり。OpenTofu provider あり | 初期化に管理者作成の一手間が要る |
| Gitea | Forgejo とほぼ同じ | svalabs/forgejo は Forgejo 専用で、Gitea 用 provider を流用するより素直 |
| GitLab CE | 機能豊富 | 重い。学習環境には過剰 |
| bare リポ + post-receive hook | 最小構成 | Webhook 相当を自作することになる |

## 影響

管理者の作成は `forgejo admin user create` を OpenTofu の provisioner から呼ぶ（→ 0003、0009）。

Webhook の送信先はプライベートアドレス（doco-cd コンテナ）なので、`FORGEJO__webhook__ALLOWED_HOST_LIST` は当初案の `*`（全許可）ではなく、より狭い `private` を採用した。

## 参考

- <https://forgejo.org/docs/latest/admin/installation-docker/>
- <https://registry.terraform.io/providers/svalabs/forgejo/latest>
