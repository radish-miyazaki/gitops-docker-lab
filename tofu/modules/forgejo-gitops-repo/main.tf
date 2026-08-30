resource "forgejo_repository" "this" {
  owner          = var.owner
  name           = var.name
  description    = var.description
  private        = true
  default_branch = "main"
  # 初回 push は seed スクリプトが行うので、README などは作らない
  auto_init = false
}

resource "forgejo_repository_webhook" "push" {
  repository_id = forgejo_repository.this.id
  type          = "forgejo"
  active        = true
  events        = ["push"]
  branch_filter = "main"
  config = {
    url          = var.webhook_url
    content_type = "json"
    secret       = var.webhook_secret
  }
}

resource "forgejo_collaborator" "reader" {
  repository_id = forgejo_repository.this.id
  user          = var.collaborator_username
  permission    = "read"
}
