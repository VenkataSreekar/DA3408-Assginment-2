import json, re
import pandas as pd
from kubernetes import client, config

RESULT_LINE_RE = re.compile(r"RESULT_JSON:(\{.*\})")

def load_kube_config():
    try:
        config.load_kube_config()
    except Exception:
        config.load_incluster_config()

def collect(job_name, namespace="default"):
    load_kube_config()
    v1 = client.CoreV1Api()
    pods = v1.list_namespaced_pod(namespace=namespace, label_selector=f"job-name={job_name}")
    rows = []
    for pod in pods.items:
        logs = v1.read_namespaced_pod_log(name=pod.metadata.name, namespace=namespace)
        match = RESULT_LINE_RE.search(logs)
        if match:
            rows.append(json.loads(match.group(1)))
    df = pd.DataFrame(rows).sort_values("completion_index").reset_index(drop=True)
    return df

if __name__ == "__main__":
    df = collect("shard-validation-job")
    print(df.to_string(index=False))
    print("\nTotal invalid rows across all shards:", df["invalid_rows"].sum())