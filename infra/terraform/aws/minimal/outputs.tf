output "aws_region" {
  value = var.aws_region
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "bucket_name" {
  value = aws_s3_bucket.reports.bucket
}

output "object_store_endpoint" {
  value = "https://s3.${var.aws_region}.amazonaws.com"
}

output "object_store_access_key" {
  value = aws_iam_access_key.object_store.id
}

output "object_store_secret_key" {
  value     = aws_iam_access_key.object_store.secret
  sensitive = true
}

output "postgres_address" {
  value = aws_db_instance.postgres.address
}

output "postgres_port" {
  value = aws_db_instance.postgres.port
}

output "postgres_database" {
  value = aws_db_instance.postgres.db_name
}

output "postgres_username" {
  value = aws_db_instance.postgres.username
}

output "postgres_dsn" {
  value     = "postgres://${aws_db_instance.postgres.username}:${var.db_password}@${aws_db_instance.postgres.address}:${aws_db_instance.postgres.port}/${aws_db_instance.postgres.db_name}"
  sensitive = true
}
