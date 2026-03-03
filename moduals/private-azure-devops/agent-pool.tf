resource "azuredevops_agent_pool" "" {
  name           = ""
  auto_provision = false
  auto_update    = false
}
resource "azuredevops_agent_queue" "" {
  project_id    = azuredevops_project.example.id
  agent_pool_id = data.azuredevops_agent_pool.example.id
}

# Grant access to queue to all pipelines in the project
resource "azuredevops_resource_authorization" "example" {
  project_id  = azuredevops_project.example.id
  resource_id = azuredevops_agent_queue.example.id
  type        = "queue"
  authorized  = true
}