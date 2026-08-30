# local-tls-cert

mkcert でローカル CA と `*.gitops.localhost` の証明書を作り、volume にだけ置く。ホストに鍵を残さない。

初回は `mkcert -install` が OS の信頼ストアを触るため、管理者確認（macOS ならキーチェーンのパスワード）が 1 度だけ出る。`install_ca = false` にすると登録を飛ばせるが、その場合ブラウザと `curl` は証明書を信頼しない。

`mkcert` と `docker` が PATH に要る。`mise run` 経由で実行すれば mise が両方を通す。

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
| [terraform_data.this](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| certs\_volume\_id | 証明書と鍵を書く Docker volume の ID。作り直しの検出に使う | `string` | n/a | yes |
| certs\_volume\_name | 証明書と鍵を書く Docker volume 名 | `string` | n/a | yes |
| domain | 証明書を発行するドメイン。ワイルドカードと apex の両方を SAN に入れる | `string` | n/a | yes |
| install\_ca | mkcert -install でローカル CA を OS の信頼ストアに登録するか。初回は管理者確認が出る | `bool` | `true` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| cert\_file | volume 内の証明書ファイル名 |
| key\_file | volume 内の秘密鍵ファイル名 |
<!-- END_TF_DOCS -->