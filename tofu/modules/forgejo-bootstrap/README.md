# forgejo-bootstrap

Forgejo の管理者と doco-cd 用ユーザーを作り、秘匿値を Docker volume に書く。秘匿値は ephemeral 変数で受け取り、tfstate には残さない（ADR 0009）。

作り直すときは `tofu apply -replace=module.forgejo_bootstrap.terraform_data.bootstrap` ではなく、Forgejo の volume も消える `mise run destroy` から入る。ユーザーが既に存在すると `user create` が失敗するため。

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.11 |

## Providers

| Name | Version |
| ---- | ------- |
| terraform | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [terraform_data.bootstrap](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| admin\_password | Forgejo 管理者のパスワード。ephemeral な値を渡す | `string` | n/a | yes |
| container\_name | Forgejo コンテナ名。docker exec の対象 | `string` | n/a | yes |
| forgejo\_container\_id | Forgejo コンテナの ID。triggers\_replace 用で、コンテナが作り直されたことの検出にだけ使う | `string` | n/a | yes |
| forgejo\_data\_volume\_id | Forgejo のデータ volume の ID。triggers\_replace 用で、volume が作り直されたことの検出にだけ使う | `string` | n/a | yes |
| grafana\_admin\_password | Grafana 管理者のパスワード。ephemeral な値を渡す | `string` | n/a | yes |
| secrets\_volume\_name | 秘匿値を書く Docker volume 名 | `string` | n/a | yes |
| webhook\_secret | Webhook の secret。ephemeral な値を渡す | `string` | n/a | yes |
| admin\_email | Forgejo 管理者のメールアドレス。ローカル用のダミーでよい | `string` | `"admin@localhost.invalid"` | no |
| admin\_username | Forgejo 管理者のユーザー名。Forgejo は admin を予約語として拒否するため既定値は別名にしてある | `string` | `"lab-admin"` | no |
| forgejo\_port | Forgejo コンテナ内の HTTP ポート | `number` | `3000` | no |
| service\_email | doco-cd ユーザーのメールアドレス | `string` | `"doco-cd@localhost.invalid"` | no |
| service\_username | doco-cd が Git 認証に使うユーザー名 | `string` | `"doco-cd"` | no |
| token\_scopes | doco-cd ユーザーのトークンに付けるスコープ | `string` | `"read:repository"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| admin\_username | Forgejo 管理者のユーザー名 |
| id | bootstrap 完了を待つための依存用 ID |
| service\_username | doco-cd が Git 認証に使うユーザー名 |
<!-- END_TF_DOCS -->
