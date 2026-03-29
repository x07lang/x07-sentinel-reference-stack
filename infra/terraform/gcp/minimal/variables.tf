variable "project_id" {
  description = "GCP project id"
  type        = string
}

variable "region" {
  description = "Primary region"
  type        = string
}

variable "project_name" {
  description = "Short project name prefix"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "orders"
}

variable "db_username" {
  description = "PostgreSQL username"
  type        = string
  default     = "orders_app"
}

variable "db_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "gke_release_channel" {
  description = "GKE release channel"
  type        = string
  default     = "REGULAR"
}

variable "node_machine_type" {
  description = "GKE node machine type"
  type        = string
  default     = "e2-standard-4"
}
