# sample-app

doco-cd のデプロイ対象。`scripts/seed-sample-app.sh` が Forgejo の `gitops-lab/sample-app` に初回 push する。push 後は Forgejo 側が正で、このディレクトリは雛形にすぎない。

変更を試すときは Forgejo から clone して `html/index.html` の版数を上げ、push する。
