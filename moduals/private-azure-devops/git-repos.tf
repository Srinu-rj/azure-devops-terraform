#TODO==>  Create additional Git repositories within the project Create Git repository
resource "azuredevops_git_repository" "api" {
  project_id = azuredevops_project.main.id
  name       = "platform-api"
  initialization {
    init_type = "Clean"
  }
}

resource "azuredevops_serviceendpoint_snyk" "snyk_service_endpoint" {
  project_id            = azuredevops_project.main.id
  server_url            = "https://snyk.io/"
  api_token             = "00000000-0000-0000-0000-000000000000"
  service_endpoint_name = "Example Snyk"
  description           = "Managed by Terraform"
}

resource "azuredevops_serviceendpoint_sonarcloud" "sonarcloud_service_endpoint" {
  project_id            = azuredevops_project.main.id
  service_endpoint_name = "Example SonarCloud"
  token                 = "0000000000000000000000000000000000000000"
  description           = "Managed by Terraform"
}
resource "azuredevops_serviceendpoint_sonarqube" "sonarqube_service_endpoint" {
  project_id            = azuredevops_project.main.id
  service_endpoint_name = "Example SonarQube"
  url                   = "https://sonarqube.my.com"
  token                 = "0000000000000000000000000000000000000000"
  description           = "Managed by Terraform"
}

# Import a repository from GitHub
resource "azuredevops_git_repository" "back_end_java_application" {
  name       = "java-application"
  project_id = azuredevops_project.main.id

  initialization {
    init_type   = "Import"
    source_type = "Git"
    source_url  = "https://github.com/example/external-tool.git"
  }
}

resource "azuredevops_serviceendpoint_maven" "maven_service_endpoint" {
  project_id            = azuredevops_project.main.id
  service_endpoint_name = "maven-example"
  description           = "Service Endpoint for 'Maven' (Managed by Terraform)"
  url                   = "https://example.com"
  repository_id         = "example"

  authentication_token {
    token = "0000000000000000000000000000000000000000"
  }
}

resource "azuredevops_serviceendpoint_nexus" "nexus_service_endpoint" {
  project_id            = azuredevops_project.main.id
  service_endpoint_name = "nexus-example"
  description           = "Service Endpoint for 'Nexus IQ' (Managed by Terraform)"
  url                   = "https://example.com"

  username = "username"
  password = "password"
}

resource "azuredevops_serviceendpoint_npm" "nmap_service_endpoint" {
  project_id            = azuredevops_project.main.id
  service_endpoint_name = "Example npm"
  url                   = "https://registry.npmjs.org"
  access_token          = "00000000-0000-0000-0000-000000000000"
  description           = "Managed by Terraform"
}

resource "azuredevops_serviceendpoint_nuget" "asp_net_service_endpoint" {
  project_id            = azuredevops_project.main.id
  api_key               = "apikey"
  service_endpoint_name = "Example NuGet"
  description           = "Managed by Terraform"
}

resource "azuredevops_serviceendpoint_permissions" "service_endpoint_permissions" {
  project_id         = azuredevops_project.main.id
  principal          = data.azuredevops_group.admins.id
  serviceendpoint_id = azuredevops_serviceendpoint_dockerregistry.acr.id
  permissions = {
    Use               = "allow"
    Administer        = "deny"
    Create            = "deny"
    ViewAuthorization = "allow"
    ViewEndpoint      = "allow"
  }
}

