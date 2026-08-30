# 0007. 設定ファイルは tftpl で OpenTofu 管理し、upload で注入する

- ステータス: 採用
- 日付: 2026-08-30

## 背景

Prometheus や Grafana や doco-cd の設定ファイルには、ホスト名やポートなど OpenTofu 側で決めている値が入る。設定ファイルを別ディレクトリに素で置くと、二重管理になって食い違う。

## 決定

設定ファイルは `terraform/stacks/platform/templates/*.tftpl` に置き、`templatefile()` で描画して `docker_container` の `upload` ブロックでコンテナに入れる。
変数を含まない大きな JSON（Grafana ダッシュボード）は `.tftpl` にせず `file()` で読む。

## 検討した選択肢

| 選択肢 | 良い点 | 悪い点 |
|---|---|---|
| tftpl + upload | 値の出どころが一箇所。バインドマウントの絶対パスが不要 | 設定変更でコンテナが再作成される |
| `config/` にバインドマウント | 読みやすい | ホストの絶対パス依存。OpenTofu の変数と二重管理 |
| `docker_config`（Swarm） | 宣言的 | Swarm 専用 |

## 影響

Grafana ダッシュボードのように `${}` を多く含むファイルはテンプレートにしない。秘匿値は upload に書かず volume 経由で渡す（0009）。

## 参考

- <https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container#upload>
