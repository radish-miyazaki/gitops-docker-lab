# 0001. GitOps ツールに doco-cd を使う

- ステータス: 採用
- 日付: 2026-08-30

## 背景

Kubernetes を使わず Docker Compose で GitOps を体験したい。学習が目的なので、Git が唯一の正になる構造がそのまま見えるツールがよい。

## 決定

doco-cd を使う。Web UI がなく、Webhook とポーリングで Git を pull して `docker compose up` するだけの pull 型ツールなので、GitOps の輪郭がぼやけない。

## 検討した選択肢

| 選択肢 | 良い点 | 悪い点 |
|---|---|---|
| doco-cd | 軽量。Forgejo の Webhook に対応。Prometheus メトリクスあり | UI がない |
| Komodo | UI が充実。マルチサーバー管理 | UI から直接操作できるので Git を正とする運用規律が別に要る。Core と Periphery と DB で構成が重い |
| Portainer | 定番の Docker UI。Stack の Git 自動更新あり | GitOps 機能は簡易。UI 主体 |
| ComposeFlux | Flux 風の headless | ポーリングのみ。個人開発で情報が少ない |
| Forgejo Actions で自作 | ツール不要 | push 型（CI が deploy する）で、pull 型 GitOps とは別物 |

## 影響

可視化は別に用意する必要がある（→ 0005）。

## 参考

- <https://github.com/kimdre/doco-cd>
- <https://doco.cd/latest/>
