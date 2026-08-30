# 0010. IaC ツールに OpenTofu を使う

- ステータス: 採用
- 日付: 2026-08-30

## 背景

当初は Terraform 1.14 を想定していた。ephemeral resource と write-only 引数（0009）を使う前提なので、乗り換えるならこの 2 つが使える必要がある。

## 決定

OpenTofu（1.11 以上）を使う。
1.11 で ephemeral resource、write-only 引数、`ephemeral = true` の変数と出力が入っており、0009 の設計をそのまま実装できる。
provider は OpenTofu のレジストリから同じ名前で取れる。ディレクトリ名は `terraform/`、CLI は `tofu`。

## 検討した選択肢

| 選択肢 | 良い点 | 悪い点 |
|---|---|---|
| OpenTofu | オープンソース（MPL）。必要な機能は 1.11 でそろっている | Terraform 向けの記事をそのまま読むと CLI 名が違う |
| Terraform 1.14 | 情報が多い | BSL ライセンス。学習用途なら問題ないが、試す動機が薄い |

## 影響

`terraform_remote_state` や `terraform_data` の名前は OpenTofu でも同じ。tflint と terraform-docs は `.tf` を読むだけなのでそのまま使える。tfstate に `terraform_version` として OpenTofu のバージョンが入る。

## 参考

- <https://opentofu.org/docs/v1.11/intro/whats-new/>
- <https://opentofu.org/docs/v1.11/language/ephemerality/ephemeral-resources/>
- 0009
