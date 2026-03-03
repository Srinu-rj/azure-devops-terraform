import time


#TODO  After triggering a run, you usually want to monitor its progress. Here is a polling approach that waits for completion:
def wait_for_pipeline_run(pipeline_id, run_id, timeout_minutes=30):
    """Poll the pipeline run status until it completes or times out."""
    start_time = time.time()
    timeout_seconds = timeout_minutes * 60

    while True:
        response = requests.get(
            f"{base_url}/pipelines/{pipeline_id}/runs/{run_id}?api-version=7.1",
            auth=auth
        )
        run = response.json()
        state = run["state"]
        result = run.get("result", "pending")

        print(f"Run {run_id}: state={state}, result={result}")

        if state == "completed":
            return run

        # Check for timeout
        elapsed = time.time() - start_time
        if elapsed > timeout_seconds:
            raise TimeoutError(f"Pipeline run did not complete within {timeout_minutes} minutes")

        time.sleep(30)  # Poll every 30 seconds to avoid rate limits