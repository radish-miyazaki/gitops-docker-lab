# docker-service

コンテナ 1 つを同じ形で起こすための薄い包み。ロジックは持たない。

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.11 |
| docker | ~> 4.5 |

## Providers

| Name | Version |
| ---- | ------- |
| docker | ~> 4.5 |

## Resources

| Name | Type |
| ---- | ---- |
| [docker_container.this](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| image | docker\_image の image\_id か、タグ付きイメージ名 | `string` | n/a | yes |
| name | コンテナ名。ネットワーク内のホスト名にもなる | `string` | n/a | yes |
| network\_name | 接続する Docker ネットワーク名 | `string` | n/a | yes |
| binds | ホストパスのバインドマウント。docker.sock のような特殊用途だけに使う | <pre>list(object({<br/>    host_path      = string<br/>    container_path = string<br/>    read_only      = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| env | 環境変数。KEY=VALUE 形式。秘匿値は渡さない（tfstate に残るため） | `list(string)` | `[]` | no |
| healthcheck | ヘルスチェック。null なら設定しない | <pre>object({<br/>    test         = list(string)<br/>    interval     = optional(string, "10s")<br/>    timeout      = optional(string, "5s")<br/>    retries      = optional(number, 5)<br/>    start_period = optional(string, "10s")<br/>  })</pre> | `null` | no |
| ports | 公開ポート。external を省くとホストに公開しない | <pre>list(object({<br/>    internal = number<br/>    external = optional(number)<br/>  }))</pre> | `[]` | no |
| uploads | コンテナ内パス => ファイル内容。設定ファイルの注入に使う。秘匿値は渡さない | `map(string)` | `{}` | no |
| user | 実行ユーザー。null ならイメージの既定 | `string` | `null` | no |
| volumes | 名前付き volume のマウント | <pre>list(object({<br/>    volume_name    = string<br/>    container_path = string<br/>    read_only      = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| wait\_for\_healthy | true なら healthcheck が通るまで create を待つ | `bool` | `false` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| container\_id | コンテナ ID |
| container\_name | コンテナ名 |
<!-- END_TF_DOCS -->
