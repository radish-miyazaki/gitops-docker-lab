# 0008. doco-cd の Git 認証は専用ユーザーのトークンで行う

- ステータス: 採用
- 日付: 2026-08-30

## 背景

doco-cd が private リポを clone するにはトークンが要る。トークンを forgejo スタックで作ると、その値を platform スタックの doco-cd コンテナに戻す必要があり、依存が双方向になる。

## 決定

platform スタックの bootstrap で Forgejo ユーザー `doco-cd` を作り、`read:repository` スコープのトークンを発行して `lab-secrets/git_token` に書く。
forgejo スタックはリポの collaborator に `doco-cd` を read 権限で加えるだけにする。
これで apply は platform → forgejo の一方向で済む。

## 検討した選択肢

| 選択肢 | 良い点 | 悪い点 |
|---|---|---|
| platform で専用ユーザーとトークンを作る | 依存が一方向 | provisioner でユーザーを作る |
| forgejo スタックで `forgejo_personal_access_token` を作る | OpenTofu リソースで完結 | トークンが state に残る。platform に戻す経路が要る |
| 管理者トークンを doco-cd に渡す | 手順が少ない | 権限過剰 |

## 影響

トークンは state に残らない（0009）。

## 参考

- 0003
- 0009
