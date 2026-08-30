# 0011. Traefik でローカル HTTPS と名前によるルーティングを行う

- ステータス: 採用
- 日付: 2026-08-30

## 背景

サービスごとにホストのポートを割り当てていたため、`localhost:3000` `localhost:3001` `localhost:8000` のように番号を覚える必要があった。
番号は増えるほど衝突しやすく、他のツールと取り合いにもなる。
加えて Forgejo の `ROOT_URL` が `http://` のままだと、ブラウザの警告や Cookie の扱いなど、実運用との差が学習の妨げになる。
ローカルでも名前で到達し、HTTPS で終端したい。

## 決定

Traefik v3 をリバースプロキシとして置き、ホストに公開するポートは Traefik の 80 と 443 だけにする。
ルーティングは Docker provider がコンテナのラベルから読む（`exposedByDefault: false` なので、ラベルを付けたコンテナだけが公開される）。
ドメインは `gitops.localhost` を使う。`.localhost` は RFC 6761 の特別用途名でリゾルバがループバックに解決する決まりになっている。
macOS でも `*.gitops.localhost` が 127.0.0.1 と ::1 の両方に解決されることを実測したので、Traefik の 80 / 443 は IPv4 と IPv6 の両方で公開する。
証明書は mkcert のローカル CA で `*.gitops.localhost` と apex の 2 つを SAN に持つものを 1 枚発行し、Traefik の file provider に既定証明書として読ませる。
証明書と鍵は Docker volume `lab-certs` にだけ置き、ホストの作業ディレクトリには残さない。

## 検討した選択肢

| 選択肢 | 良い点 | 悪い点 |
|---|---|---|
| Traefik + mkcert | Docker ラベルだけでルーティングが決まり、コンテナを足すのが簡単。証明書はローカル CA なので警告が出ない | mkcert のローカル CA を OS の信頼ストアに入れる必要がある |
| Caddy | 設定が短い。自動 HTTPS が売り | 自動 HTTPS は公的 CA 前提で、ローカルでは結局内部 CA の運用になる。Docker ラベル連携は別プラグインが要る |
| nginx-proxy | 枯れている | TLS の自動化が弱く、`acme-companion` を足しても公的 CA 前提。設定の見通しも悪い |
| 自己署名証明書をそのまま使う | 追加のツールが要らない | ブラウザと `curl` が毎回警告を出し、体験が悪い |
| `*.localtest.me` などの公開 DNS | 名前解決の設定が不要 | 名前解決に外部 DNS が要るのでオフラインで動かない |

## 影響

- ホストの公開ポートは 80 / 443 だけになり、`docker ps` で衝突の有無をひと目で確認できる。サービスを足すときはラベルを付けるだけでよい
- 80 / 443 は `0.0.0.0` と `::` の両方に bind する。`.localhost` が ::1 にも解決される以上、Happy Eyeballs で IPv4 へ落ちないクライアントを取りこぼさないため
- 初回の apply で `mkcert -install` が走り、管理者確認（macOS はキーチェーンのパスワード）が 1 度だけ出る。`install_local_ca = false` で飛ばせるが、その場合は証明書が信頼されない
- 証明書と鍵は `lab-certs` volume にだけ存在する。`mise run destroy` で volume ごと消え、次の apply で作り直される
- Forgejo の `ROOT_URL` が `https://forgejo.gitops.localhost/` になる。Webhook が届ける clone URL もこの形になるため、
  doco-cd の `SOURCE_URL_REWRITES_FILE` がコンテナ間の `http://forgejo:3000/` へ書き換える（ADR 0007 のテンプレートに値として渡している）
- TLS の終端は Traefik が行い、Forgejo 自身は `PROTOCOL=http` のまま動く
- Traefik のダッシュボードは `api.dashboard: true` で有効だが、ルーターを定義していないのでホストからは開けない。コンテナの中からだけ到達できる。必要になったら router を 1 つ足す
- ポートを指定する `*_host_port` 変数は無くなった。ドメインを変えたいときは `domain` 変数を使う

## 参考

- <https://doc.traefik.io/traefik/providers/docker/>
- <https://datatracker.ietf.org/doc/html/rfc6761#section-6.3>
- <https://github.com/FiloSottile/mkcert>
- 0007、0009
