# 0003. OpenTofu を platform と forgejo の 2 スタックに分ける

- ステータス: 採用
- 日付: 2026-08-30

## 背景

forgejo provider は Forgejo が起動して管理者が存在しないと使えない。コンテナ起動と Forgejo 内リソースを 1 つの root module に置くと、provider 設定が同じ module 内のリソースに依存する循環になる。

## 決定

`terraform/stacks/platform`（docker provider）と `terraform/stacks/forgejo`（forgejo provider）に分け、platform → forgejo の順に apply する。受け渡しは `terraform_remote_state` だけ。ディレクトリ名は役割で付け、番号は付けない。

## 検討した選択肢

| 選択肢 | 良い点 | 悪い点 |
|---|---|---|
| 2 スタック | 依存が一方向で分かりやすい | apply が 2 回になる |
| 1 スタック + `-target` | ディレクトリが 1 つ | `-target` は例外操作で、毎回の手順にするものではない |
| 番号付きディレクトリ (`01-`, `02-`) | 順序が名前で分かる | 一般的な慣習ではない。順序は README と mise task で示せる |

## 影響

`mise run bootstrap` が順序を担う。スタックが増えたら `stacks/README.md` に依存を書く。

## 参考

- <https://developer.hashicorp.com/terraform/language/style>
