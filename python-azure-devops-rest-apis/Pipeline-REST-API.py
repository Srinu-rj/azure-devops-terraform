import requests
import json

# Auth setup (same as above)
org = "myorganization"
project = "myproject"
pat = "your-pat"
auth = ("", pat)
base_url = f"https://dev.azure.com/{org}/{project}/_apis"

# Define the pipeline configuration
# This maps a YAML file in a repo to a new pipeline definition
pipeline_body = {
    "name": "my-service-ci",
    "folder": "\\CI Pipelines",
    "configuration": {
        "type": "yaml",
        "path": "/pipelines/ci-build.yml",
        "repository": {
            "id": "your-repo-id",  # GUID of the Azure Repos Git repository
            "name": "my-service",
            "type": "azureReposGit"
        }
    }
}

# Create the pipeline
response = requests.post(
    f"{base_url}/pipelines?api-version=7.1",
    auth=auth,
    json=pipeline_body
)

if response.status_code == 200:
    pipeline = response.json()
    print(f"Created pipeline: {pipeline['name']} (ID: {pipeline['id']})")
else:
    print(f"Error: {response.status_code} - {response.text}")

# Fetch all repositories in the project to find the right ID
repos_response = requests.get(
    f"https://dev.azure.com/{org}/{project}/_apis/git/repositories?api-version=7.1",
    auth=auth
)

for repo in repos_response.json()["value"]:
    print(f"{repo['name']}: {repo['id']}")

# Trigger a pipeline run with optional parameters
run_body = {
    "resources": {
        "repositories": {
            "self": {
                "refName": "refs/heads/main"  # Branch to build
            }
        }
    },
    "templateParameters": {
        "environment": "staging",  # Custom parameter defined in YAML
        "runTests": "true"
    }
}

pipeline_id = 42  # The ID returned when you created the pipeline

response = requests.post(
    f"{base_url}/pipelines/{pipeline_id}/runs?api-version=7.1",
    auth=auth,
    json=run_body
)

run = response.json()
print(f"Pipeline run started: {run['id']} - State: {run['state']}")