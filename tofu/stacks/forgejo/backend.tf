# state は手元にだけ置く。platform の state は terraform_remote_state で読むだけで、書き戻しはしない
terraform {
  backend "local" {}
}
