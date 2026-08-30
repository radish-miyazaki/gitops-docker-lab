# state は手元にだけ置く。forgejo スタックが terraform_remote_state で読む
terraform {
  backend "local" {}
}
