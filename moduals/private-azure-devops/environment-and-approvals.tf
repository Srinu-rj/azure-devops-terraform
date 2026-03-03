# Create deployment environments
resource "azuredevops_environment" "dev_environment" {
  project_id = azuredevops_project.main.id
  name       = "dev"
}
resource "azuredevops_environment" "qa_environment" {
  project_id = azuredevops_project.main.id
  name       = "qa"
}
resource "azuredevops_environment" "production_environment" {
  project_id = azuredevops_project.main.id
  name       = "Production"
}

resource "azuredevops_environment" "staging_environment" {
  project_id = azuredevops_project.main.id
  name       = "Staging"
}
