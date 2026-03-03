# TODO => MAVEN FEED
resource "azuredevops_feed" "maven_feed" {
  name = "maven_feed"
  features {
    permanent_delete = false
  }
}

resource "azuredevops_feed_permission" "maven_feed_permission" {
  feed_id             = azuredevops_feed.maven_feed.id
  role                = "reader"
  identity_descriptor = azuredevops_group.example.descriptor
}

resource "azuredevops_feed_retention_policy" "feed_retention_policy" {
  feed_id                                   = azuredevops_feed.maven_feed.id
  count_limit                               = 20
  days_to_keep_recently_downloaded_packages = 30
}