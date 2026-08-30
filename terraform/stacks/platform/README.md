# stacks/platform

Docker 上に Forgejo と doco-cd と Prometheus と Grafana を起こす。秘匿値は `lab-secrets` volume にだけ書く。

apply 後に `../forgejo` を apply する。順序は `mise run bootstrap` が担う。

秘匿値は 3 つの `ephemeral "random_password"`（hashicorp/random）で生成する。ephemeral な値は tfstate に残らないため、terraform-docs は一覧に載せない。

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.11 |
| docker | ~> 4.5 |
| random | ~> 3.9 |

## Providers

| Name | Version |
| ---- | ------- |
| docker | 4.5.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| doco\_cd | ../../modules/docker-service | n/a |
| forgejo | ../../modules/docker-service | n/a |
| forgejo\_bootstrap | ../../modules/forgejo-bootstrap | n/a |
| grafana | ../../modules/docker-service | n/a |
| local\_tls\_cert | ../../modules/local-tls-cert | n/a |
| prometheus | ../../modules/docker-service | n/a |
| traefik | ../../modules/docker-service | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [docker_image.doco_cd](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image) | resource |
| [docker_image.forgejo](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image) | resource |
| [docker_image.grafana](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image) | resource |
| [docker_image.prometheus](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image) | resource |
| [docker_image.traefik](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image) | resource |
| [docker_network.lab](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/network) | resource |
| [docker_volume.certs](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/volume) | resource |
| [docker_volume.doco_cd_data](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/volume) | resource |
| [docker_volume.forgejo_data](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/volume) | resource |
| [docker_volume.grafana_data](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/volume) | resource |
| [docker_volume.prometheus_data](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/volume) | resource |
| [docker_volume.secrets](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/volume) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| certs\_volume\_name | 証明書を置く Docker volume 名 | `string` | `"lab-certs"` | no |
| docker\_host | Docker デーモンの接続先。Docker Desktop の標準ソケットを既定にし、OrbStack などは DOCKER\_HOST で上書きする | `string` | `"unix:///var/run/docker.sock"` | no |
| doco\_cd\_image | doco-cd のイメージ | `string` | `"ghcr.io/kimdre/doco-cd:0.113.0"` | no |
| domain | ラボのドメイン。各サービスは <name>.<domain> で公開する。.localhost は DNS なしで 127.0.0.1 と ::1 に解決される | `string` | `"gitops.localhost"` | no |
| forgejo\_admin\_username | Forgejo 管理者のユーザー名。Forgejo は admin を予約語として拒否するため既定値は別名にしてある | `string` | `"lab-admin"` | no |
| forgejo\_image | Forgejo のイメージ | `string` | `"codeberg.org/forgejo/forgejo:16"` | no |
| grafana\_image | Grafana のイメージ | `string` | `"grafana/grafana:12.1.1"` | no |
| install\_local\_ca | mkcert のローカル CA を OS の信頼ストアに登録するか | `bool` | `true` | no |
| network\_name | 全コンテナが属する Docker ネットワーク名 | `string` | `"gitops-lab"` | no |
| org\_name | Forgejo 上の組織名。forgejo スタックと doco-cd のポーリング設定で使う | `string` | `"gitops-lab"` | no |
| poll\_interval | doco-cd のポーリング間隔。Webhook の取りこぼしを拾う | `string` | `"5m"` | no |
| prometheus\_image | Prometheus のイメージ | `string` | `"prom/prometheus:v3.5.0"` | no |
| sample\_app\_repo\_name | デプロイ対象リポ名 | `string` | `"sample-app"` | no |
| secrets\_volume\_name | 秘匿値を置く Docker volume 名 | `string` | `"lab-secrets"` | no |
| traefik\_image | Traefik のイメージ | `string` | `"traefik:v3.6"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| doco\_cd\_username | doco-cd が Git 認証に使うユーザー名 |
| doco\_cd\_webhook\_url | Forgejo の Webhook に登録する URL |
| domain | ラボのドメイン |
| forgejo\_admin\_username | Forgejo 管理者のユーザー名 |
| forgejo\_url\_host | ホストから使う Forgejo の URL |
| forgejo\_url\_internal | コンテナ間で使う Forgejo の URL |
| org\_name | Forgejo 上の組織名 |
| sample\_app\_repo\_name | デプロイ対象リポ名 |
| secrets\_volume\_name | 秘匿値を置いた Docker volume 名 |
| urls | 各サービスの URL |
<!-- END_TF_DOCS -->
