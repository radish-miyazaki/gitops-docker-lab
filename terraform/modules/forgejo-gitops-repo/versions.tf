terraform {
  required_version = ">= 1.11"

  required_providers {
    forgejo = {
      source  = "svalabs/forgejo"
      version = "~> 1.6"
    }
  }
}
