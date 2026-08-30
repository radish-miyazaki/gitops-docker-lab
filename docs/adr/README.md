# ADR 一覧

意思決定の記録。書き方は [template.md](template.md)。

| 番号 | タイトル | ステータス | 日付 |
|---|---|---|---|
| [0001](0001-gitops-tool-doco-cd.md) | GitOps ツールに doco-cd を使う | 採用 | 2026-08-30 |
| [0002](0002-forgejo-as-vcs.md) | VCS に Forgejo を使う | 採用 | 2026-08-30 |
| [0003](0003-opentofu-two-stacks.md) | OpenTofu を platform と forgejo の 2 スタックに分ける | 採用 | 2026-08-30 |
| [0004](0004-repo-separation.md) | 基盤リポとアプリリポを分ける | 採用 | 2026-08-30 |
| [0005](0005-observability-prometheus-grafana.md) | 可視化に Prometheus と Grafana を使う | 採用 | 2026-08-30 |
| [0006](0006-no-secrets-in-repo.md) | リポジトリと tfstate に秘匿情報を置かない | 採用 | 2026-08-30 |
| [0007](0007-config-as-tftpl.md) | 設定ファイルは tftpl で OpenTofu 管理し、upload で注入する | 採用 | 2026-08-30 |
| [0008](0008-doco-cd-service-user.md) | doco-cd の Git 認証は専用ユーザーのトークンで行う | 採用 | 2026-08-30 |
| [0009](0009-secrets-via-ephemeral-and-volume.md) | 秘匿値は ephemeral と Docker volume で受け渡す | 採用 | 2026-08-30 |
| [0010](0010-opentofu.md) | IaC ツールに OpenTofu を使う | 採用 | 2026-08-30 |
