# 0010. IaC ツールに OpenTofu を使う

- ステータス: 採用
- 日付: 2026-08-30

## 背景

ephemeral resource（Terraform 1.10）と write-only 引数（1.11）は Terraform でも使え、OpenTofu 固有の機能ではない。この機能差は選定理由にならない。

## 決定

OpenTofu（1.11 以上）を使う。MPL 2.0 で配布されており、Terraform との差分を実際に試したいという学習上の動機がある。加えて、0009 の設計に必要な ephemeral resource と `ephemeral` 変数・出力が 1.11 でそろっていることをスキーマで確認できた。

## 検討した選択肢

| 選択肢 | 良い点 | 悪い点 |
|---|---|---|
| OpenTofu | オープンソース（MPL）。学習の動機がある | Terraform 向けの情報を読み替える手間。provider の機能追従がわずかに遅れることがある（write-only 対応の provider が少ない点は両者共通） |
| Terraform 1.14 | 情報が多い | BSL 1.1。試す動機が弱い |

## 影響

ディレクトリ名は `terraform/`、CLI は `tofu`。provider は OpenTofu のレジストリから同じ名前で取れる。
`terraform_remote_state` や `terraform_data` の名前は OpenTofu でも同じ。tflint と terraform-docs は `.tf` を読むだけなのでそのまま使える。tfstate に `terraform_version` として OpenTofu のバージョンが入る。

## 参考

- <https://opentofu.org/docs/v1.11/intro/whats-new/>
- <https://opentofu.org/docs/v1.11/language/ephemerality/ephemeral-resources/>
- 0009
