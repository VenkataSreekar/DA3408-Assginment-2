import os, re, socket, json, time
import pandas as pd

EMAIL_RE = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")

def main():
    completion_index = int(os.environ.get("JOB_COMPLETION_INDEX", "0"))
    shard_path = f"/app/shards/shard_{completion_index}.csv"

    pod_name = os.environ.get("POD_NAME", socket.gethostname())
    node_name = os.environ.get("NODE_NAME", "unknown")

    df = pd.read_csv(shard_path, keep_default_na=False)

    invalid_count = 0
    for _, row in df.iterrows():
        email_ok = bool(EMAIL_RE.match(str(row["email"])))
        name_ok = str(row["name"]).strip() != ""
        if not (email_ok and name_ok):
            invalid_count += 1

    time.sleep(8)

    result = {
        "completion_index": completion_index,
        "shard": f"shard_{completion_index}.csv",
        "total_rows": len(df),
        "invalid_rows": invalid_count,
        "pod_name": pod_name,
        "node_name": node_name,
    }
    print("RESULT_JSON:" + json.dumps(result), flush=True)

if __name__ == "__main__":
    main()