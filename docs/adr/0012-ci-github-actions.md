# 0012. GitHub Actions で lint を回す

- ステータス: 採用
- 日付: 2026-08-30

## 背景

`mise run lint` はローカルで手動実行するしかなく、push し忘れれば lint を通していないコミットが残る。
このリポは GitHub に公開しているため、CI を足して push / PR のたびに機械的に検査したい。
一方でこの環境は Docker Compose ありきで、`apply` は実マシンの Docker と mkcert のローカル CA に依存するため、CI では回せない（回す価値もない）。

## 決定

GitHub Actions で `lint` ジョブ 1 つだけを回す。
中身は既存の `mise run lint`（tofu fmt/validate、tflint、ryl、rumdl、shellcheck、gitleaks）をそのまま呼ぶだけで、CI 専用のロジックは持たない。
`permissions` は `contents: read` のみに絞る。
`actions/checkout` と `jdx/mise-action` はどちらもタグではなくコミット SHA で固定し、バージョンをコメントで添える。
タグは差し替えられるが SHA は変わらないため、サプライチェーン対策として一般的な手法である。
SHA 固定だと自動更新が止まるので、Dependabot の `github-actions` エコシステムで SHA の更新 PR を追わせる。
`apply` を伴う E2E は CI では行わない。

## 検討した選択肢

| 選択肢 | 良い点 | 悪い点 |
|---|---|---|
| GitHub Actions + SHA 固定 + Dependabot | 公開先が GitHub なので追加設定なしで動く。SHA 固定で改ざんに強く、Dependabot が更新を追う | ワークフロー自体の維持が要る |
| Forgejo Actions | 構文が GitHub Actions とほぼ互換で、将来 Forgejo 側に移すのも容易 | このリポの公開先は GitHub であり、今 Forgejo Actions を使う理由がない |
| Action をタグ指定（例 `@v4`） | 記述が短い | タグは後から差し替え可能で、意図しないコードが実行されるリスクがある |

## 影響

- push と PR のたびに `mise run lint` が自動で走り、通っていないコミットが `main` に残りにくくなる
- `cargo:ryl` は CI で毎回 Rust からビルドするため初回のジョブが遅い（キャッシュが無い状態でおよそ数分〜10 分程度かかりうる）。
  `jdx/mise-action` の `cache: true` で 2 回目以降のジョブは mise のインストール・ツール一式がキャッシュから復元され短縮される。
  cold build が CI の実用上のボトルネックになるようなら、`"cargo:ryl"` をバイナリ配布のあるバックエンド（例 `"ubi:owenlamont/ryl"` のような ubi backend）に切り替える案を検討する。
  ただし `.mise.toml` の変更は本タスクの範囲外とし、別タスクで扱う
- Docker を使う `apply` / E2E は CI に含めないため、実機での動作確認は引き続き手元で `mise run bootstrap` を回す必要がある
- Action の SHA は Dependabot の PR でのみ更新する運用になり、手で SHA を書き換える機会は基本的にない

## 参考

- <https://github.com/jdx/mise-action>
- <https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions>
- <https://docs.github.com/en/code-security/dependabot/working-with-dependabot/dependabot-options-reference>
