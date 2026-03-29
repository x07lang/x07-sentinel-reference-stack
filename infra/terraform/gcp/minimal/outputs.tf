output "project_id" {
  value = var.project_id
}

output "cluster_name" {
  value = google_container_cluster.this.name
}

output "cluster_location" {
  value = var.region
}

output "bucket_name" {
  value = google_storage_bucket.reports.name
}

output "object_store_endpoint" {
  value = "https://storage.googleapis.com"
}

output "postgres_private_ip" {
  value = google_sql_database_instance.postgres.private_ip_address
}

output "postgres_database" {
  value = google_sql_database.orders.name
}

output "postgres_username" {
  value = google_sql_user.orders_app.name
}

output "postgres_dsn" {
  value     = "postgres://${google_sql_user.orders_app.name}:${var.db_password}@${google_sql_database_instance.postgres.private_ip_address}:5432/${google_sql_database.orders.name}"
  sensitive = true
}

output "storage_access_id" {
  value = google_storage_hmac_key.storage.access_id
}

output "storage_secret" {
  value     = google_storage_hmac_key.storage.secret
  sensitive = true
}
