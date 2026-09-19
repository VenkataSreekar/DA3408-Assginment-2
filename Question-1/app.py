import os
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import joblib
import redis

MODEL_PATH = os.environ.get("MODEL_PATH", "model.joblib")
REDIS_HOST = os.environ.get("REDIS_HOST", "localhost")
REDIS_PORT = int(os.environ.get("REDIS_PORT", 6379))
CACHE_TTL_SECONDS = int(os.environ.get("CACHE_TTL_SECONDS", 250))

app = FastAPI(title="Spam Detection API")
_model = None


@app.on_event("startup")
def load_model():
    global _model, _cache
    _model = joblib.load(MODEL_PATH)
    _cache = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)
    print(f"Model loaded from {MODEL_PATH}; Redis at {REDIS_HOST}:{REDIS_PORT}")


class Message(BaseModel):
    text: str


@app.get("/healthz")
def healthz():
    if _model is None:
        raise HTTPException(status_code=503, detail="Model not loaded yet")
    return {"status": "ok", "version": "v2"}


@app.post("/predict")
def predict(msg: Message):
    if _model is None:
        raise HTTPException(status_code=503, detail="Model not loaded yet")

    cached_label = _cache.get(msg.text)
    if cached_label is not None:
        return {"label": cached_label}

    label = _model.predict([msg.text])[0]
    _cache.set(msg.text, label, ex=CACHE_TTL_SECONDS)
    return {"label": label}
