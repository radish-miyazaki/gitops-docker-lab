# 0006. リポジトリと tfstate に秘匿情報を置かない

- ステータス: 採用
- 日付: 2026-08-30

## 背景

このリポは public に公開する。ローカル完結の学習環境でも、パスワードやトークンが一度でもコミットされれば履歴に残る。

## 決定

秘匿値は人が決めず、`tofu apply` 時に ephemeral resource で生成する。
保存先は Docker volume `lab-secrets` だけにし、tfstate にも残さない（実現方法は 0009）。
`.gitignore` で `*.tfstate*` `*.tfvars` `.env` を除外し、prek の gitleaks でコミット前に止める。
ドキュメントの例は `<REDACTED>` と書く。

例外: forgejo provider に write-only 引数がないため、Webhook secret は forgejo スタックの tfstate に残る。state をコミットしないことで担保する。

## 検討した選択肢

| 選択肢 | 良い点 | 悪い点 |
|---|---|---|
| ephemeral + volume | state にも残らない | provider の対応に左右される。受け渡しに provisioner が要る |
| `random_password` resource + sensitive output | 単純 | tfstate に平文で残る |
| `.env` を手で書いて gitignore | よくある形 | 人が決める値が発生し、誤コミットの余地が残る |

## 影響

秘匿値を見るには `mise run creds` を使う。tfstate をコミットしないルールは README にも書く。

## 参考

- 0009
- <https://developer.hashicorp.com/terraform/language/resources/ephemeral>
