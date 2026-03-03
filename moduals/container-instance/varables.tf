variable "location" {
  type        = string
  description = "Resource group location"
}

variable "container_rg_name" {
  type        = string
  description = "Resource group name"
}

variable "container_app_environment_name" {
  type        = string
}

variable "container_job" {
  type        = string
}

variable "log_analytics_name" {
  type        = string
}

variable "log_analytics_location" {
  type        = string
}

variable "log_analytics_rg" {
  type        = string
}

variable "log_analytics_sku" {
  type        = string
}

variable "log_retention_days" {
  type        = number
}

variable "logs_destination" {
  type        = string
}

variable "replica_timeout" {
  type = number
}

variable "replica_retry_limit" {
  type = number
}

variable "parallelism" {
  type = number
}

variable "replica_completion_count" {
  type = number
}

variable "container_name" {
  type = string
}

variable "container_image" {
  type = string
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = string
}

variable "readiness_transport" {
  type = string
}

variable "readiness_port" {
  type = number
}

variable "liveness_transport" {
  type = string
}

variable "liveness_port" {
  type = number
}

variable "liveness_path" {
  type = string
}

variable "liveness_header_name" {
  type = string
}

variable "liveness_header_value" {
  type = string
}

variable "liveness_initial_delay" {
  type = number
}

variable "liveness_interval" {
  type = number
}

variable "liveness_timeout" {
  type = number
}

variable "liveness_failure_threshold" {
  type = number
}

variable "startup_transport" {
  type = string
}

variable "startup_port" {
  type = number
}
