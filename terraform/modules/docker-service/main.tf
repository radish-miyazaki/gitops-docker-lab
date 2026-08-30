resource "docker_container" "this" {
  name    = var.name
  image   = var.image
  restart = "unless-stopped"
  user    = var.user
  env     = var.env

  # healthcheck 付きのサービスを依存元が待てるようにする
  wait         = var.wait_for_healthy
  wait_timeout = 120

  networks_advanced {
    name    = var.network_name
    aliases = [var.name]
  }

  dynamic "ports" {
    for_each = var.ports
    content {
      internal = ports.value.internal
      external = ports.value.external
      ip       = ports.value.ip
    }
  }

  dynamic "volumes" {
    for_each = var.volumes
    content {
      volume_name    = volumes.value.volume_name
      container_path = volumes.value.container_path
      read_only      = volumes.value.read_only
    }
  }

  dynamic "volumes" {
    for_each = var.binds
    content {
      host_path      = volumes.value.host_path
      container_path = volumes.value.container_path
      read_only      = volumes.value.read_only
    }
  }

  dynamic "labels" {
    for_each = var.labels
    content {
      label = labels.key
      value = labels.value
    }
  }

  dynamic "upload" {
    for_each = var.uploads
    content {
      file    = upload.key
      content = upload.value
    }
  }

  dynamic "healthcheck" {
    for_each = var.healthcheck == null ? [] : [var.healthcheck]
    content {
      test         = healthcheck.value.test
      interval     = healthcheck.value.interval
      timeout      = healthcheck.value.timeout
      retries      = healthcheck.value.retries
      start_period = healthcheck.value.start_period
    }
  }
}
