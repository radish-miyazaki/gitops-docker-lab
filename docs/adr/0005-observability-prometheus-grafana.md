# 0005. 可視化に Prometheus と Grafana を使う

- ステータス: 採用
- 日付: 2026-08-30

## 背景

doco-cd に UI はない。push から反映までの流れを目で追えないと、学習環境として物足りない。

## 決定

doco-cd の `/metrics`（`doco_cd_*`）を Prometheus で 15 秒ごとに scrape し、Grafana にダッシュボードを 1 枚 provisioning する。載せるのはデプロイ回数と失敗数、デプロイ所要時間、Webhook 受信数、ポーリング回数。

## 検討した選択肢

| 選択肢 | 良い点 | 悪い点 |
|---|---|---|
| Prometheus + Grafana | 標準的。doco-cd が対応済み | コンテナが 2 つ増える |
| doco-cd のログだけ | 追加なし | 時系列で見られない |
| Komodo に乗り換え | UI 内蔵 | 0001 の理由で不採用 |

## 影響

Grafana の匿名閲覧を有効にし、ログインなしでダッシュボードを見られるようにする。

## 参考

- 0001
