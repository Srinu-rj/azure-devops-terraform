# List of services that all follow the same repo and pipeline pattern
#TODO==> Here is where the automation really pays off. Suppose you have 20 microservices that all need the same CI pipeline setup. Instead of clicking through the UI 20 times, you can script the whole thing:
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
