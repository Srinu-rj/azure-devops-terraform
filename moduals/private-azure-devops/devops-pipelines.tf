# CI pipeline definition
resource "azuredevops_build_definition" "ci" {
  project_id = azuredevops_project.main.id
  name       = "Platform API - CI"
  path       = "\\Pipelines\\CI"

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type   = azuredevops_git_repository.back_end_java_application
    repo_id     = azuredevops_git_repository.back_end_java_application.id
    branch_name = "refs/heads/main"
    yml_path    = "azure-pipelines.yml"
  }

  variable_groups = [
    azuredevops_variable_group.common.id
  ]

  variable {
    name  = "BuildConfiguration"
    value = "Release"
  }
}

# CD pipeline definition
resource "azuredevops_build_definition" "cd" {
  project_id = azuredevops_project.main.id
  name       = "Platform API - CD"
  path       = "\\Pipelines\\CD"

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.api.id
    branch_name = "refs/heads/main"
    yml_path    = "azure-pipelines-cd.yml"
  }

  variable_groups = [
    azuredevops_variable_group.docker_variables.id,
    azuredevops_variable_group.docker_variables.id
  ]
}
