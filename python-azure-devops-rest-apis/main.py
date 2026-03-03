# ── azure_devops_client.py ────────────────────────────
from azure.devops.connection import Connection
from azure.devops.v7_0.pipelines.models import RunPipelineParameters
from msrest.authentication import BasicAuthentication
import json

# ── Connection Setup ──────────────────────────────────
PAT         = "YOUR_PAT_TOKEN"
ORG_URL     = "https://dev.azure.com/sreenivasad0208"
PROJECT     = "myproject"

credentials = BasicAuthentication("", PAT)
connection  = Connection(base_url=ORG_URL, creds=credentials)

# ── Build Client ──────────────────────────────────────
build_client    = connection.clients.get_build_client()
pipeline_client = connection.clients.get_pipelines_client()
git_client      = connection.clients.get_git_client()
work_client     = connection.clients.get_work_item_tracking_client()

# ── 1. List all pipelines ─────────────────────────────
def list_pipelines():
    pipelines = pipeline_client.list_pipelines(PROJECT)
    for p in pipelines:
        print(f"  ID: {p.id} | Name: {p.name}")
    return pipelines

# ── 2. Trigger pipeline ───────────────────────────────
def trigger_pipeline(pipeline_id: int, branch: str = "main"):
    params = RunPipelineParameters(
        resources={
            "repositories": {
                "self": {"ref_name": f"refs/heads/{branch}"}
            }
        }
    )
    run = pipeline_client.run_pipeline(params, PROJECT, pipeline_id)
    print(f"✅ Pipeline triggered — Run ID: {run.id} | State: {run.state}")
    return run

# ── 3. Get build status ───────────────────────────────
def get_build_status(build_id: int):
    build = build_client.get_build(PROJECT, build_id)
    print(f"  Build: {build.id} | Status: {build.status} | Result: {build.result}")
    return build

# ── 4. List repositories ──────────────────────────────
def list_repos():
    repos = git_client.get_repositories(PROJECT)
    for r in repos:
        print(f"  Repo: {r.name} | Default Branch: {r.default_branch}")
    return repos

# ── 5. Create work item ───────────────────────────────
def create_work_item(title: str, assigned_to: str, work_item_type: str = "Task"):
    document = [
        {"op": "add", "path": "/fields/System.Title",      "value": title},
        {"op": "add", "path": "/fields/System.AssignedTo", "value": assigned_to},
        {"op": "add", "path": "/fields/System.State",      "value": "Active"},
    ]
    item = work_client.create_work_item(document, PROJECT, work_item_type)
    print(f"✅ Work item created — ID: {item.id} | Title: {title}")
    return item

# ── 6. Get agents in pool ─────────────────────────────
def get_agent_pools():
    task_client = connection.clients.get_task_agent_client()
    pools = task_client.get_agent_pools()
    for pool in pools:
        print(f"  Pool: {pool.name} | ID: {pool.id}")
    return pools

# ── Main ──────────────────────────────────────────────
if __name__ == "__main__":
    print("\n📋 Pipelines:")
    list_pipelines()

    print("\n🚀 Triggering pipeline:")
    trigger_pipeline(pipeline_id=1, branch="main")

    print("\n📁 Repositories:")
    list_repos()

    print("\n📝 Creating work item:")
    create_work_item(
        title="Deploy to production",
        assigned_to="adminuser@company.com"
    )

    print("\n🖥️ Agent Pools:")
    get_agent_pools()