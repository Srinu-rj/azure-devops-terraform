# Create teams within the project
resource "azuredevops_team" "backend" {
  project_id = azuredevops_project.main.id
  name       = "Backend Team"
  description = "Backend developers"
}

resource "azuredevops_team" "devops" {
  project_id = azuredevops_project.main.id
  name       = "DevOps Team"
  description = "DevOps and platform engineers"
}

# Look up Azure DevOps groups
data "azuredevops_group" "contributors" {
  project_id = azuredevops_project.main.id
  name       = "Contributors"
}

data "azuredevops_group" "admins" {
  project_id = azuredevops_project.main.id
  name       = "Project Administrators"
}

output "project_id" {
  description = "Azure DevOps project ID"
  value       = azuredevops_project.main.id
}

output "project_url" {
  description = "Azure DevOps project URL"
  value       = "https://dev.azure.com/my-organization/${azuredevops_project.main.name}"
}
