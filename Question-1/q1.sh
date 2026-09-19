#!/bin/bash

# Run it from Question-1 directory

docker build -t spam-api:naive -f Dockerfile.naive .
docker images spam-api:naive
docker run -d -p 8000:8000 --name spam-naive spam-api:naive
sleep 2
curl http://localhost:8000/healthz
curl -X POST http://localhost:8000/predict -H "Content-Type: application/json" -d '{"text":"WIN a FREE iPhone now!"}'
curl -X POST http://localhost:8000/predict -H "Content-Type: application/json" -d '{"text":"Are we still on for lunch Friday?"}'
docker logs spam-naive
docker stop spam-naive
docker rm spam-naive

docker build -t spam-api:multi -f Dockerfile .
docker images spam-api:multi
docker run -d -p 8000:8000 --name spam-multi spam-api:multi
sleep 2
curl http://localhost:8000/healthz
curl -X POST http://localhost:8000/predict -H "Content-Type: application/json" -d '{"text":"WIN a FREE iPhone now!"}'
curl -X POST http://localhost:8000/predict -H "Content-Type: application/json" -d '{"text":"Are we still on for lunch Friday?"}'
docker logs spam-multi
docker stop spam-multi
docker rm spam-multi
