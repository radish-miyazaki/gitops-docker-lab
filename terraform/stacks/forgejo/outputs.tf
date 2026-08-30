output "sample_app_clone_url_host" {
  description = "ホストから clone する URL"
  value       = module.sample_app.clone_url
}

output "sample_app_html_url" {
  description = "ブラウザで開く URL"
  value       = module.sample_app.html_url
}
