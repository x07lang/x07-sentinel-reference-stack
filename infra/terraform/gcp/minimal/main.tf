locals {
  name = "${var.project_name}-${var.environment}"
}

resource "google_project_service" "services" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "storage.googleapis.com",
    "sqladmin.googleapis.com",
    "servicenetworking.googleapis.com",
    "iam.googleapis.com"
  ])

  service                    = each.key
  disable_on_destroy          = false
  disable_dependent_services = true
}

resource "google_compute_network" "this" {
  name                    = "${local.name}-vpc"
  auto_create_subnetworks = false
  depends_on              = [google_project_service.services]
}

resource "google_compute_subnetwork" "this" {
  name          = "${local.name}-subnet"
  ip_cidr_range = "10.52.0.0/20"
  region        = var.region
  network       = google_compute_network.this.id

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.53.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.54.0.0/20"
  }
}

resource "google_compute_global_address" "private_service_range" {
  name          = "${local.name}-private-services"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.this.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.this.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_range.name]
}

resource "google_container_cluster" "this" {
  name     = "${local.name}-gke"
  location = var.region

  deletion_protection = false

  network    = google_compute_network.this.id
  subnetwork = google_compute_subnetwork.this.id

  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = var.gke_release_channel
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  depends_on = [google_project_service.services]
}

resource "google_container_node_pool" "default" {
  name       = "${local.name}-default"
  location   = var.region
  cluster    = google_container_cluster.this.name
  node_count = 2

  node_config {
    machine_type = var.node_machine_type
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

resource "google_sql_database_instance" "postgres" {
  name             = "${local.name}-pg"
  region           = var.region
  database_version = "POSTGRES_16"

  deletion_protection = false

  settings {
    tier              = "db-custom-1-3840"
    availability_type = "ZONAL"

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.this.id
    }

    backup_configuration {
      enabled = true
    }
  }

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

resource "google_sql_database" "orders" {
  name     = var.db_name
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "orders_app" {
  name     = var.db_username
  instance = google_sql_database_instance.postgres.name
  password = var.db_password
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "google_storage_bucket" "reports" {
  name                        = "${local.name}-reports-${random_id.bucket_suffix.hex}"
  location                    = var.region
  force_destroy               = false
  uniform_bucket_level_access = true
}

resource "google_service_account" "storage" {
  account_id   = "${replace(local.name, "-", "")}obj"
  display_name = "Reference stack object storage"
}

resource "google_storage_hmac_key" "storage" {
  service_account_email = google_service_account.storage.email
}
