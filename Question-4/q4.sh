# ---------- Build and sanity-check image standalone (before Kubernetes) ----------
docker build -t spam-api:v1 -f ../Question-1/Dockerfile ../Question-1
docker run -d -p 8001:8000 --name spam-test spam-api:v1
sleep 2
docker ps -a | grep spam-test
docker logs spam-test
curl http://localhost:8001/healthz
docker stop spam-test
docker rm spam-test

# ---------- Start a clean 2-node minikube cluster ----------
minikube delete
minikube start --nodes 2 --cpus 2 --memory 2048 --driver=docker
kubectl get nodes

# ---------- Load image into minikube ----------
minikube image load spam-api:v1
minikube image ls | grep spam-api

# ---------- Apply manifests ----------
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get pods -o wide

# ---------- Reach the service via port-forward on 8090 ----------
kubectl port-forward svc/spam-api-svc 8090:80 &
PF_PID=$!
sleep 3
curl http://localhost:8090/healthz
curl -X POST http://localhost:8090/predict -H "Content-Type: application/json" -d '{"text":"WIN a FREE iPhone now!"}'
curl -X POST http://localhost:8090/predict -H "Content-Type: application/json" -d '{"text":"Are we still on for lunch Friday?"}'

# ---------- Self-healing test ----------
kubectl get pods -o wide
# copy one pod name from above, then:
# kubectl delete pod <pod-name>
# kubectl get pods -w   (watch it get recreated, Ctrl+C once Ready)

# ---------- Rolling update test ----------
docker build -t spam-api:v2 -f ../Question-1/Dockerfile ../Question-1
minikube image load spam-api:v2
kubectl set image deployment/spam-api spam-api=spam-api:v2
kubectl rollout status deployment/spam-api
kubectl rollout history deployment/spam-api
curl http://localhost:8090/healthz

# ---------- Cleanup ----------
kill $PF_PID