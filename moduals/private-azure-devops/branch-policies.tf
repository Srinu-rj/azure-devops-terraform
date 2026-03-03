resource "azuredevops_user_entitlement" "user_entitlement" {
  principal_name       = "mail@email.com"
  account_license_type = "basic"
}

# Require minimum number of reviewers on the main branch
resource "azuredevops_branch_policy_min_reviewers" "main" {
  project_id = azuredevops_project.main.id
  enabled  = true
  blocking = true
  auto_reviewer_ids  = [azuredevops_user_entitlement.user_entitlement.id]
  submitter_can_vote = false
  message            = "Auto reviewer"
  path_filters       = ["*/src/*.ts"]

  settings {
    reviewer_count                         = 2
    submitter_can_vote                     = false
    last_pusher_cannot_approve             = true
    allow_completion_with_rejects_or_waits = false
    on_push_reset_approved_votes           = true

    scope {
      repository_id  = azuredevops_git_repository.api.id
      repository_ref = "refs/heads/main"
      match_type     = "Exact"
    }
  }
}

# Require linked work items
resource "azuredevops_branch_policy_work_item_linking" "main" {
  project_id = azuredevops_project.main.id

  enabled  = true
  blocking = true

  settings {
    scope {
      repository_id  = azuredevops_git_repository.api.id
      repository_ref = "refs/heads/main"
      match_type     = "Exact"
    }
  }
}

# Require comment resolution
resource "azuredevops_branch_policy_comment_resolution" "main" {
  project_id = azuredevops_project.main.id

  enabled  = true
  blocking = true

  settings {
    scope {
      repository_id  = azuredevops_git_repository.api.id
      repository_ref = "refs/heads/main"
      match_type     = "Exact"
    }
  }
}

# Build validation policy (require CI to pass before merge)
resource "azuredevops_branch_policy_build_validation" "main" {
  project_id = azuredevops_project.main.id

  enabled  = true
  blocking = true

  settings {
    display_name        = "CI Build Validation"
    build_definition_id = azuredevops_build_definition.ci.id
    valid_duration      = 720 # 12 hours
    filename_patterns   = [
      "/src/*",
      "!/docs/*"
    ]

    scope {
      repository_id  = azuredevops_git_repository.api.id
      repository_ref = "refs/heads/main"
      match_type     = "Exact"
    }
  }
}
