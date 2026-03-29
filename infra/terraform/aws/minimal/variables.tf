variable "aws_region" {
  description = "AWS region"
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

variable "kubernetes_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "vpc_cidr" {
  description = "Primary VPC CIDR"
  type        = string
  default     = "10.42.0.0/16"
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "orders"
}

variable "db_username" {
  description = "PostgreSQL admin username"
  type        = string
  default     = "orders_app"
}

variable "db_password" {
  description = "PostgreSQL admin password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "node_instance_types" {
  description = "EKS managed node group instance types"
  type        = list(string)
  default     = ["t3.large"]
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
