tags = {
  environment = "dev"
  project     = "apigw-ecs"
  terraform   = "true"
}

region             = "us-east-1"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

api_stage_name = "dev"

api_logs_retention_days = 30

api_proxy = "https://echo.free.beeceptor.com"

cluster_name = "dev-cluster"

task_files = ["./env/dev/tasks/app.json"]

openapi_file = "./env/dev/openapi.yml"

desired_tasks_count = {
  "app" = 1
}