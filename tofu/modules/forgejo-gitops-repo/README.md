# forgejo-gitops-repo

GitOps の対象リポを 1 つ作る。リポと push Webhook と読み取り専用 collaborator をひとまとめにする。

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.11 |
| forgejo | ~> 1.6 |

## Providers

| Name | Version |
| ---- | ------- |
| forgejo | ~> 1.6 |

## Resources

| Name | Type |
| ---- | ---- |
| [forgejo_collaborator.reader](https://registry.terraform.io/providers/svalabs/forgejo/latest/docs/resources/collaborator) | resource |
| [forgejo_repository.this](https://registry.terraform.io/providers/svalabs/forgejo/latest/docs/resources/repository) | resource |
| [forgejo_repository_webhook.push](https://registry.terraform.io/providers/svalabs/forgejo/latest/docs/resources/repository_webhook) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| collaborator\_username | read 権限で加えるユーザー名（doco-cd） | `string` | n/a | yes |
| name | リポ名 | `string` | n/a | yes |
| owner | リポの所有者（組織名） | `string` | n/a | yes |
| webhook\_secret | Webhook の署名に使う secret。forgejo provider に write-only 引数がないため state に残る | `string` | n/a | yes |
| webhook\_url | push を通知する URL | `string` | n/a | yes |
| description | リポの説明 | `string` | `""` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| clone\_url | HTTP の clone URL（ROOT\_URL 基準） |
| html\_url | ブラウザで開く URL |
| repository\_id | リポ ID |
<!-- END_TF_DOCS -->
