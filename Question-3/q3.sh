#!/bin/bash

# ---------- 1. Generate the 8 shards ----------
python generate_shards.py
ls shards/

# ---------- 2. Local sanity check of the worker script ----------
for i in 0 1 2; do
  JOB_COMPLETION_INDEX=$i POD_NAME=local NODE_NAME=local python validate_worker.py
done

# ---------- 3. Start a clean 2-node minikube cluster ----------
minikube start --nodes 2 --cpus 2 --memory 2048 --driver=docker
sleep 20
kubectl get nodes

# ---------- 4. Build the worker image ----------
docker build -t shard-validator:latest -f Dockerfile.job .

# ---------- 5. Load the image onto the primary (control-plane) node ----------
minikube image load shard-validator:latest
minikube image ls | grep shard-validator

# ---------- 6. Load the image onto the worker node (minikube-m02) ----------
# minikube's default image load only reaches the primary node, so the image
# must be manually copied onto every additional node via save/cp/load.
docker save shard-validator:latest -o shard-validator.tar
minikube cp shard-validator.tar minikube-m02:/tmp/shard-validator.tar
minikube ssh -n minikube-m02 -- docker load -i /tmp/shard-validator.tar
minikube ssh -n minikube-m02 -- docker images | grep shard-validator
rm shard-validator.tar

# ---------- 7. Apply the Indexed Job and watch for concurrency ----------
kubectl apply -f job-shard-validation.yaml
kubectl get pods -o wide
sleep 10
kubectl get pods -o wide
kubectl get job shard-validation-job

# ---------- 8. Collect results via the Kubernetes API ----------
pip install kubernetes
python collect_results.py

# ---------- 9. Cross-check against the original generator output ----------
python generate_shards.py

# ---------- 10. Clean up the Job ----------
kubectl delete job shard-validation-job