import random
import pandas as pd
import os

random.seed(42)
os.makedirs("shards", exist_ok=True)

DOMAINS = ["gmail.com", "yahoo.com", "outlook.com", "example.com"]
NAMES = ["Alice", "Bob", "Carol", "David", "Eve", "Frank", "Grace", "Heidi"]

def make_shard(shard_id, n_rows=50):
    n_invalid = random.randint(2, 8)
    rows = []
    invalid_indices = set(random.sample(range(n_rows), n_invalid))
    for i in range(n_rows):
        name = random.choice(NAMES)
        if i in invalid_indices:
            if random.random() < 0.5:
                email = f"{name.lower()}AT{random.choice(DOMAINS)}"
            else:
                email = f"{name.lower()}@{random.choice(DOMAINS)}"
                name = ""
        else:
            email = f"{name.lower()}{i}@{random.choice(DOMAINS)}"
        rows.append({"id": f"{shard_id}-{i}", "name": name, "email": email})
    df = pd.DataFrame(rows)
    df.to_csv(f"shards/shard_{shard_id}.csv", index=False)
    print(f"shard_{shard_id}.csv: {n_rows} rows, {n_invalid} deliberately invalid")

for shard_id in range(8):
    make_shard(shard_id)