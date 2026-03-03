location                       = "southeastasia"
container_rg_name              = "container-rg"
container_app_environment_name = "container-env"
container_job                  = "spring-job"

log_analytics_name     = "law-spring"
log_analytics_location = "southeastasia"
log_analytics_rg       = "container-rg"
log_analytics_sku      = "PerGB2018"
log_retention_days     = 30

logs_destination = "log-analytics"

replica_timeout          = 10
replica_retry_limit      = 3
parallelism              = 2
replica_completion_count = 1

container_name  = "spring-container"
container_image = "srinu641/bbd4962541ce:v1.0"
cpu             = 1.5
memory          = "1Gi"

readiness_transport = "HTTP"
readiness_port      = 80

liveness_transport         = "HTTP"
liveness_port              = 80
liveness_path              = "/health"
liveness_header_name       = "Cache-Control"
liveness_header_value      = "no-cache"
liveness_initial_delay     = 5
liveness_interval          = 20
liveness_timeout           = 2
liveness_failure_threshold = 1

startup_transport = "HTTP"
startup_port      = 80
