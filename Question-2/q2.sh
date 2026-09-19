docker compose up --build -d
sleep 3
docker compose ps
docker compose logs api
docker compose logs cache

curl http://localhost:8080/healthz

# First call -- expect "cache":"miss", note the timing
time curl -X POST http://localhost:8080/predict -H "Content-Type: application/json" -d '{"text":"WIN a FREE iPhone now!"}'

# Second call, identical input -- expect "cache":"hit", should be faster
time curl -X POST http://localhost:8080/predict -H "Content-Type: application/json" -d '{"text":"WIN a FREE iPhone now!"}'

# Confirm ham still works correctly too
curl -X POST http://localhost:8080/predict -H "Content-Type: application/json" -d '{"text":"Are we still on for lunch Friday?"}'

# Peek into Redis directly to confirm the key was actually stored
docker compose exec cache redis-cli KEYS '*'

docker compose down
