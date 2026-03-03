import requests
import json

# Configuration for Azure DevOps API access
org = "myorganization"
project = "myproject"
pat = "your-personal-access-token"

# Azure DevOps uses Basic auth with empty username and PAT as password
auth = ("", pat)
base_url = f"https://dev.azure.com/{org}/{project}/_apis"

# Verify the connection by fetching project info
response = requests.get(
    f"{base_url}/build/definitions?api-version=7.1",
    auth=auth
)
print(f"Found {response.json()['count']} pipeline definitions")

# List of services that all follow the same repo and pipeline pattern
services = [
    "user-service",
    "order-service",
    "payment-service",
    "notification-service",
    "inventory-service",
]

created_pipelines = []

for service in services:
    # Look up the repository ID for this service
    repo_resp = requests.get(
        f"https://dev.azure.com/{org}/{project}/_apis/git/repositories/{service}?api-version=7.1",
        auth=auth
    )

    if repo_resp.status_code != 200:
        print(f"Repository {service} not found, skipping")
        continue

    repo_id = repo_resp.json()["id"]

    # Create the pipeline definition pointing to the shared YAML template
    pipeline_body = {
        "name": f"{service}-ci",
        "folder": "\\Microservices",
        "configuration": {
            "type": "yaml",
            "path": "/azure-pipelines.yml",
            "repository": {
                "id": repo_id,
                "name": service,
                "type": "azureReposGit"
            }
        }
    }

    resp = requests.post(
        f"{base_url}/pipelines?api-version=7.1",
        auth=auth,
        json=pipeline_body
    )

    if resp.status_code == 200:
        pipeline = resp.json()
        created_pipelines.append(pipeline)
        print(f"Created: {pipeline['name']} (ID: {pipeline['id']})")
    else:
        print(f"Failed to create pipeline for {service}: {resp.text}")

print(f"\nSuccessfully created {len(created_pipelines)} pipelines")

# ==============================================================================

# Fetch the current build definition
def_id = 42
response = requests.get(
    f"{base_url}/build/definitions/{def_id}?api-version=7.1",
    auth=auth
)
definition = response.json()

# Add or update variables on the definition
definition["variables"] = {
    "DOCKER_REGISTRY": {"value": "myregistry.azurecr.io", "isSecret": False},
    "IMAGE_TAG": {"value": "$(Build.BuildId)", "isSecret": False},
    "REGISTRY_PASSWORD": {"value": None, "isSecret": True}  # Secret variables
}

# Push the updated definition back
update_resp = requests.put(
    f"{base_url}/build/definitions/{def_id}?api-version=7.1",
    auth=auth,
    json=definition
)

print(f"Updated definition: {update_resp.status_code}")