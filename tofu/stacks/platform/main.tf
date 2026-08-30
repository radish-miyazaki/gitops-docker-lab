resource "docker_network" "lab" {
  name = var.network_name
}

resource "docker_volume" "forgejo_data" {
  name = "forgejo-data"
}

resource "docker_volume" "doco_cd_data" {
  name = "doco-cd-data"
}

resource "docker_volume" "prometheus_data" {
  name = "prometheus-data"
}

resource "docker_volume" "grafana_data" {
  name = "grafana-data"
}

resource "docker_volume" "secrets" {
  name = var.secrets_volume_name
}

resource "docker_image" "forgejo" {
  name = var.forgejo_image
}

resource "docker_image" "doco_cd" {
  name = var.doco_cd_image
}

resource "docker_image" "prometheus" {
  name = var.prometheus_image
}

resource "docker_image" "grafana" {
  name = var.grafana_image
}

# 秘匿値は state に残さない。値は bootstrap の provisioner だけが受け取る（ADR 0009）
ephemeral "random_password" "forgejo_admin" {
  length  = 24
  special = false
}

ephemeral "random_password" "webhook_secret" {
  length  = 32
  special = false
}

ephemeral "random_password" "grafana_admin" {
  length  = 24
  special = false
}

module "forgejo" {
  source = "../../modules/docker-service"

  name         = "forgejo"
  image        = docker_image.forgejo.image_id
  network_name = docker_network.lab.name
  ports = [
    { internal = local.forgejo_internal_port, external = var.forgejo_host_port },
  ]
  env = [
    "USER_UID=1000",
    "USER_GID=1000",
    # インストール画面を出さず、env の設定だけで起動させる
    "FORGEJO__security__INSTALL_LOCK=true",
    "FORGEJO__database__DB_TYPE=sqlite3",
    "FORGEJO__server__DOMAIN=localhost",
    "FORGEJO__server__HTTP_PORT=${local.forgejo_internal_port}",
    "FORGEJO__server__ROOT_URL=${local.forgejo_url_host}",
    "FORGEJO__service__DISABLE_REGISTRATION=true",
    # Webhook の送信先 doco-cd はプライベートアドレスなので許可が要る
    "FORGEJO__webhook__ALLOWED_HOST_LIST=private",
  ]
  volumes = [
    { volume_name = docker_volume.forgejo_data.name, container_path = "/data" },
  ]
  healthcheck = {
    test = ["CMD", "curl", "-sf", "http://localhost:${local.forgejo_internal_port}/api/healthz"]
  }
  wait_for_healthy = true
}

module "forgejo_bootstrap" {
  source = "../../modules/forgejo-bootstrap"

  container_name         = module.forgejo.container_name
  admin_username         = var.forgejo_admin_username
  secrets_volume_name    = docker_volume.secrets.name
  admin_password         = ephemeral.random_password.forgejo_admin.result
  webhook_secret         = ephemeral.random_password.webhook_secret.result
  grafana_admin_password = ephemeral.random_password.grafana_admin.result
}

module "doco_cd" {
  source = "../../modules/docker-service"

  name         = "doco-cd"
  image        = docker_image.doco_cd.image_id
  network_name = docker_network.lab.name
  ports = [
    { internal = local.doco_cd_http_port, external = var.doco_cd_host_port },
  ]
  env = [
    "TZ=Asia/Tokyo",
    "LOG_LEVEL=info",
    "HTTP_PORT=${local.doco_cd_http_port}",
    "METRICS_PORT=${local.doco_cd_metrics_port}",
    "GIT_ACCESS_TOKEN_USER=${module.forgejo_bootstrap.service_username}",
    "GIT_ACCESS_TOKEN_FILE=${local.secrets_mount_path}/git_token",
    "WEBHOOK_SECRET_FILE=${local.secrets_mount_path}/webhook_secret",
    "POLL_CONFIG_FILE=/config/poll.yaml",
    "SOURCE_URL_REWRITES_FILE=/config/source-rewrites.yaml",
  ]
  volumes = [
    { volume_name = docker_volume.doco_cd_data.name, container_path = "/data" },
    { volume_name = docker_volume.secrets.name, container_path = local.secrets_mount_path, read_only = true },
  ]
  binds = [
    { host_path = "/var/run/docker.sock", container_path = "/var/run/docker.sock" },
  ]
  uploads = {
    "/config/poll.yaml" = templatefile("${path.module}/templates/doco-cd-poll.yaml.tftpl", {
      clone_url = local.sample_app_clone_url_internal
      interval  = var.poll_interval
    })
    "/config/source-rewrites.yaml" = templatefile("${path.module}/templates/doco-cd-source-rewrites.yaml.tftpl", {
      host_url     = local.forgejo_url_host
      internal_url = local.forgejo_url_internal
    })
  }

  # git_token と webhook_secret が volume に書かれてから起動させる
  depends_on = [module.forgejo_bootstrap]
}

module "prometheus" {
  source = "../../modules/docker-service"

  name         = "prometheus"
  image        = docker_image.prometheus.image_id
  network_name = docker_network.lab.name
  ports = [
    { internal = 9090, external = var.prometheus_host_port },
  ]
  volumes = [
    { volume_name = docker_volume.prometheus_data.name, container_path = "/prometheus" },
  ]
  uploads = {
    "/etc/prometheus/prometheus.yml" = templatefile("${path.module}/templates/prometheus.yml.tftpl", {
      metrics_port = local.doco_cd_metrics_port
    })
  }
}

module "grafana" {
  source = "../../modules/docker-service"

  name         = "grafana"
  image        = docker_image.grafana.image_id
  network_name = docker_network.lab.name
  ports = [
    { internal = 3000, external = var.grafana_host_port },
  ]
  env = [
    "GF_SECURITY_ADMIN_USER=admin",
    "GF_SECURITY_ADMIN_PASSWORD__FILE=${local.secrets_mount_path}/grafana_admin_password",
    # ログインなしでダッシュボードを見せる（学習環境なので閲覧は誰でもよい）
    "GF_AUTH_ANONYMOUS_ENABLED=true",
    "GF_AUTH_ANONYMOUS_ORG_ROLE=Viewer",
    "GF_USERS_ALLOW_SIGN_UP=false",
  ]
  volumes = [
    { volume_name = docker_volume.grafana_data.name, container_path = "/var/lib/grafana" },
    { volume_name = docker_volume.secrets.name, container_path = local.secrets_mount_path, read_only = true },
  ]
  uploads = {
    "/etc/grafana/provisioning/datasources/prometheus.yaml" = templatefile("${path.module}/templates/grafana-datasource.yaml.tftpl", {
      prometheus_url = "http://prometheus:9090"
    })
    "/etc/grafana/provisioning/dashboards/doco-cd.yaml" = templatefile("${path.module}/templates/grafana-dashboard-provider.yaml.tftpl", {
      dashboards_path = "/etc/grafana/dashboards"
    })
    # /var/lib/grafana は volume なので、upload が volume 初期化に隠れない場所に置く
    "/etc/grafana/dashboards/doco-cd.json" = file("${path.module}/templates/grafana-dashboard.json")
  }

  depends_on = [module.forgejo_bootstrap]
}
