provider "docker" {
  # DOCKER_HOST があれば OrbStack などのソケットを優先する。無ければ標準ソケット
  host = coalesce(trimspace(try(env("DOCKER_HOST"), "")), var.docker_host)
}
