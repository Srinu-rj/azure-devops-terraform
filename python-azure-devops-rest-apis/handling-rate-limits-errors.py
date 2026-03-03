import time

def api_request(method, url, retries=3, **kwargs):
    """Make an API request with automatic retry on rate limiting."""
    for attempt in range(retries):
        response = requests.request(method, url, auth=auth, **kwargs)

        if response.status_code == 429:
            # Rate limited - wait and retry
            retry_after = int(response.headers.get("Retry-After", 30))
            print(f"Rate limited, waiting {retry_after}s (attempt {attempt + 1})")
            time.sleep(retry_after)
            continue

        return response

    raise Exception(f"Failed after {retries} retries: {url}")