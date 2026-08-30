# stacks/forgejo

Forgejo の中に組織とデプロイ対象リポと Webhook を作る。platform スタックの apply 後に実行する。

認証情報と Webhook secret は `lab-secrets` volume から環境変数で渡す。手で動かすなら:

```sh
export FORGEJO_USERNAME="$(cd ../platform && tofu output -raw forgejo_admin_username)"
export FORGEJO_PASSWORD="$(docker run --rm -v lab-secrets:/s alpine:3.21 cat /s/forgejo_admin_password)"
export TF_VAR_webhook_secret="$(docker run --rm -v lab-secrets:/s alpine:3.21 cat /s/webhook_secret)"
tofu apply
```

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
| terraform | n/a |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| sample\_app | ../../modules/forgejo-gitops-repo | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [forgejo_organization.lab](https://registry.terraform.io/providers/svalabs/forgejo/latest/docs/resources/organization) | resource |
| [terraform_remote_state.platform](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| webhook\_secret | Webhook の secret。lab-secrets/webhook\_secret の値を TF\_VAR\_webhook\_secret で渡す。forgejo provider に write-only 引数がないため state に残る | `string` | n/a | yes |
| platform\_state\_path | platform スタックの tfstate のパス | `string` | `"../platform/terraform.tfstate"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| sample\_app\_clone\_url\_host | ホストから clone する URL |
| sample\_app\_html\_url | ブラウザで開く URL |
<!-- END_TF_DOCS -->
