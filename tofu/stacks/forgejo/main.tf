data "terraform_remote_state" "platform" {
  backend = "local"
  config = {
    path = var.platform_state_path
  }
}

resource "forgejo_organization" "lab" {
  name       = local.platform.org_name
  visibility = "private"
}

module "sample_app" {
  source = "../../modules/forgejo-gitops-repo"

  owner                 = forgejo_organization.lab.name
  name                  = local.platform.sample_app_repo_name
  description           = "doco-cd がデプロイするサンプル"
  webhook_url           = local.platform.doco_cd_webhook_url
  webhook_secret        = var.webhook_secret
  collaborator_username = local.platform.doco_cd_username
}
