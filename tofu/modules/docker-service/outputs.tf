output "container_name" {
  description = "コンテナ名"
  value       = docker_container.this.name
}

output "container_id" {
  description = "コンテナ ID"
  value       = docker_container.this.id
}
