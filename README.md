```text
DA3408-Assginment-2/
├── README.md
├── Question-1/
│   ├── app.py
│   ├── Dockerfile
│   ├── Dockerfile.naive
│   ├── model.joblib
│   ├── requirements.txt
│   ├── spam_dataset.csv
│   └── train_model.py
├── Question-2/
│   └── docker-compose.yml
├── Question-3/
│   ├── collect_results.py
│   ├── Dockerfile.job
│   ├── generate_shards.py
│   ├── job-shard-validation.yaml
│   ├── validate_worker.py
│   └── shards/
│       ├── shard_0.csv
│       ├── shard_1.csv
│       ├── shard_2.csv
│       ├── shard_3.csv
│       ├── shard_4.csv
│       ├── shard_5.csv
│       ├── shard_6.csv
│       └── shard_7.csv
└── Question-4/
	├── deployment.yaml
	└── service.yaml
```

## Question-1

`app.py` - Runs the FastAPI spam detection service with Redis-backed prediction caching.
`Dockerfile` - Builds a multi-stage production image for the spam detection API.
`Dockerfile.naive` - Builds a simple single-stage image for the spam detection API.
`model.joblib` - Stores the trained text classification pipeline used by the API.
`requirements.txt` - Lists the Python dependencies required by the API and model.
`spam_dataset.csv` - Contains the generated spam and ham messages used for training.
`train_model.py` - Generates the dataset, trains the classifier, and saves the model.

## Question-2

`docker-compose.yml` - Runs the spam API with a Redis cache using Docker Compose.

## Question-3

`collect_results.py` - Collects validation results from Kubernetes job pod logs.
`Dockerfile.job` - Builds the container image used by the shard validation workers.
`generate_shards.py` - Generates eight CSV shards containing valid and invalid records.
`job-shard-validation.yaml` - Defines the indexed Kubernetes job that validates the shards.
`validate_worker.py` - Validates one assigned shard and prints its result as JSON.
`shards/shard_0.csv` - Contains the first generated validation data shard.
`shards/shard_1.csv` - Contains the second generated validation data shard.
`shards/shard_2.csv` - Contains the third generated validation data shard.
`shards/shard_3.csv` - Contains the fourth generated validation data shard.
`shards/shard_4.csv` - Contains the fifth generated validation data shard.
`shards/shard_5.csv` - Contains the sixth generated validation data shard.
`shards/shard_6.csv` - Contains the seventh generated validation data shard.
`shards/shard_7.csv` - Contains the eighth generated validation data shard.

## Question-4

`deployment.yaml` - Defines the Kubernetes deployment for two spam API replicas.
`service.yaml` - Exposes the spam API deployment through a Kubernetes NodePort service.