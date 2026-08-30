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

resource "docker_volume" "certs" {
  name = var.certs_volume_name
}

# destroy/apply を繰り返す学習環境で再 pull を避けるため、ローカルに残す
resource "docker_image" "forgejo" {
  name         = var.forgejo_image
  keep_locally = true
}

resource "docker_image" "doco_cd" {
  name         = var.doco_cd_image
  keep_locally = true
}

resource "docker_image" "prometheus" {
  name         = var.prometheus_image
  keep_locally = true
}

resource "docker_image" "grafana" {
  name         = var.grafana_image
  keep_locally = true
}

resource "docker_image" "traefik" {
  name         = var.traefik_image
  keep_locally = true
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

module "local_tls_cert" {
  source = "../../modules/local-tls-cert"

  domain            = var.domain
  certs_volume_name = docker_volume.certs.name
  certs_volume_id   = docker_volume.certs.id
  install_ca        = var.install_local_ca
}

module "traefik" {
  source = "../../modules/docker-service"

  name         = "traefik"
  image        = docker_image.traefik.image_id
  network_name = docker_network.lab.name
  # ホストに出すポートはここだけ。他のサービスは Traefik 経由で名前で届く。
  # macOS は *.localhost を 127.0.0.1 と ::1 の両方に解決するため、
  # IPv4 だけにフォールバックしないクライアントでも届くよう両方を公開する
  ports = [
    { internal = 80, external = 80 },
    { internal = 80, external = 80, ip = "::" },
    { internal = 443, external = 443 },
    { internal = 443, external = 443, ip = "::" },
  ]
  volumes = [
    { volume_name = docker_volume.certs.name, container_path = local.certs_mount_path, read_only = true },
  ]
  binds = [
    # Docker provider がコンテナのラベルを読むために要る
    { host_path = "/var/run/docker.sock", container_path = "/var/run/docker.sock", read_only = true },
  ]
  uploads = {
    "/etc/traefik/traefik.yml" = templatefile("${path.module}/templates/traefik.yml.tftpl", {
      network = docker_network.lab.name
    })
    "/etc/traefik/dynamic/tls.yml" = templatefile("${path.module}/templates/traefik-tls.yml.tftpl", {
      certs_mount_path = local.certs_mount_path
      cert_file        = module.local_tls_cert.cert_file
      key_file         = module.local_tls_cert.key_file
    })
  }

  # 証明書が volume に書かれてから起動させる
  depends_on = [module.local_tls_cert]
}

module "forgejo" {
  source = "../../modules/docker-service"

  name         = "forgejo"
  image        = docker_image.forgejo.image_id
  network_name = docker_network.lab.name
  labels = merge(local.traefik_labels.forgejo, {
    "traefik.http.services.forgejo.loadbalancer.server.port" = tostring(local.forgejo_internal_port)
  })
  env = [
    "USER_UID=1000",
    "USER_GID=1000",
    # インストール画面を出さず、env の設定だけで起動させる
    "FORGEJO__security__INSTALL_LOCK=true",
    "FORGEJO__database__DB_TYPE=sqlite3",
    "FORGEJO__server__DOMAIN=${local.hosts.forgejo}",
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
  forgejo_container_id   = module.forgejo.container_id
  forgejo_data_volume_id = docker_volume.forgejo_data.id
  forgejo_port           = local.forgejo_internal_port
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
  labels = merge(local.traefik_labels.doco_cd, {
    "traefik.http.services.doco_cd.loadbalancer.server.port" = tostring(local.doco_cd_http_port)
  })
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
  labels = merge(local.traefik_labels.prometheus, {
    "traefik.http.services.prometheus.loadbalancer.server.port" = tostring(local.prometheus_internal_port)
  })
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
  labels = merge(local.traefik_labels.grafana, {
    "traefik.http.services.grafana.loadbalancer.server.port" = tostring(local.grafana_internal_port)
  })
  env = [
    "GF_SECURITY_ADMIN_USER=admin",
    "GF_SECURITY_ADMIN_PASSWORD__FILE=${local.secrets_mount_path}/grafana_admin_password",
    # ログインなしでダッシュボードを見せる（学習環境なので閲覧は誰でもよい）
    "GF_AUTH_ANONYMOUS_ENABLED=true",
    "GF_AUTH_ANONYMOUS_ORG_ROLE=Viewer",
    "GF_USERS_ALLOW_SIGN_UP=false",
    # リダイレクト先やダッシュボード共有 URL を Traefik 経由の名前にする
    "GF_SERVER_ROOT_URL=${local.urls.grafana}",
  ]
  volumes = [
    { volume_name = docker_volume.grafana_data.name, container_path = "/var/lib/grafana" },
    { volume_name = docker_volume.secrets.name, container_path = local.secrets_mount_path, read_only = true },
  ]
  uploads = {
    "/etc/grafana/provisioning/datasources/prometheus.yaml" = templatefile("${path.module}/templates/grafana-datasource.yaml.tftpl", {
      prometheus_url = "http://prometheus:${local.prometheus_internal_port}"
    })
    "/etc/grafana/provisioning/dashboards/doco-cd.yaml" = templatefile("${path.module}/templates/grafana-dashboard-provider.yaml.tftpl", {
      dashboards_path = "/etc/grafana/dashboards"
    })
    # /var/lib/grafana は volume なので、upload が volume 初期化に隠れない場所に置く
    "/etc/grafana/dashboards/doco-cd.json" = file("${path.module}/templates/grafana-dashboard.json")
  }

  # grafana_admin_password が volume に書かれてから起動させる
  depends_on = [module.forgejo_bootstrap]
}
