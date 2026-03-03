# Create an Azure DevOps project
resource "azuredevops_project" "main" {
  name               = "asp net"
  description        = "Platform team services and infrastructure"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"

  # Enable/disable specific features
  features = {
    "boards"       = "enabled"
    "repositories" = "enabled"
    "pipelines"    = "enabled"
    "testplans"    = "disabled"
    "artifacts"    = "enabled"
  }
}

resource "azuredevops_project_features" "main_project_feature" {
  project_id = azuredevops_project.main.id
  features = {
    testplans = "disabled"
    artifacts = "enabled"
  }
}
resource "azuredevops_project_permissions" "main_project_permission" {
  project_id = azuredevops_project.main.id
  principal  = data.azuredevops_group.admins.id

  permissions = {
    DELETE              = "Deny"
    EDIT_BUILD_STATUS   = "NotSet"
    WORK_ITEM_MOVE      = "Allow"
    DELETE_TEST_RESULTS = "Deny"
  }
}

resource "azuredevops_project_pipeline_settings" "main_project_pipeline_settings" {
  project_id = azuredevops_project.main.id

  enforce_job_scope                    = true
  enforce_referenced_repo_scoped_token = false
  enforce_settable_var                 = true
  publish_pipeline_metadata            = false
  status_badges_are_private            = true
}

resource "azuredevops_project_tags" "main_project_tag" {
  project_id = azuredevops_project.main.id
  tags       = ["tag1", "tag2"]
}
