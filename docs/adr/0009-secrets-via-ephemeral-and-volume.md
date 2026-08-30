# 0009. 秘匿値は ephemeral と Docker volume で受け渡す

- ステータス: 採用
- 日付: 2026-08-30

## 背景

OpenTofu 1.11 では ephemeral resource と write-only 引数と ephemeral 変数が使える。
ただし ephemeral な値を渡せる先は provider 設定と provisioner と ephemeral 変数・出力だけで、通常のリソース属性に渡すとエラーになる。
使う provider の対応状況は次のとおり（2026-08-30 にスキーマで確認）。

| provider | ephemeral resource | write-only 引数 |
|---|---|---|
| hashicorp/random 3.9 | `random_password` `random_bytes` | なし |
| kreuzwerker/docker 4.5 | なし | なし |
| svalabs/forgejo 1.6 | なし | なし |

`docker_container.env` に渡す方法では tfstate に平文で残る。

## 決定

- 秘匿値は `ephemeral "random_password"` で生成する
- bootstrap の `terraform_data` に付けた `local-exec` provisioner が、その値を `environment` で受け取り、Forgejo への設定と Docker volume `lab-secrets` への書き込みを行う
- 各コンテナは `*_FILE` 系の設定（doco-cd: `WEBHOOK_SECRET_FILE` `GIT_ACCESS_TOKEN_FILE`、Grafana: `GF_SECURITY_ADMIN_PASSWORD__FILE`）で volume 上のファイルを読む
- forgejo スタックは `FORGEJO_USERNAME` / `FORGEJO_PASSWORD` 環境変数で認証する。provider 設定は state に保存されない。値は mise task が volume から読んで渡す
- Webhook secret は `forgejo_repository_webhook.config.secret` に渡すしかないので、forgejo スタックの state に残る。既知の例外として受け入れる

ephemeral な値は plan ごとに変わるが、provisioner は `terraform_data` の作成時にしか動かないので、2 回目以降の apply は volume の値がそのまま使われる。

## 検討した選択肢

| 選択肢 | 良い点 | 悪い点 |
|---|---|---|
| ephemeral + provisioner + volume | tfstate に残らない | provisioner に依存。値の作り直しは `-replace` か destroy から |
| `random_password` resource + env | 単純 | state に平文 |
| 手書きの `.env` | 慣れている | 人が値を決める工程が発生する（0006 に反する） |

## 影響

秘匿値の確認は `docker run --rm -v lab-secrets:/s alpine cat /s/<name>` で行う。docker と forgejo provider が write-only 引数に対応したら、この ADR を見直す。

## 参考

- 0006
- <https://developer.hashicorp.com/terraform/language/resources/ephemeral>
- <https://developer.hashicorp.com/terraform/language/resources/ephemeral/write-only>
