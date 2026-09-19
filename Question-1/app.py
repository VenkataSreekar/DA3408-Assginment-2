import os
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import joblib

MODEL_PATH = os.environ.get("MODEL_PATH", "model.joblib")

app = FastAPI(title="Spam Detection API")
_model = None


@app.on_event("startup")
def load_model():
    global _model
    _model = joblib.load(MODEL_PATH)
    print(f"Model loaded from {MODEL_PATH}")


class Message(BaseModel):
    text: str


@app.get("/healthz")
def healthz():
    if _model is None:
        raise HTTPException(status_code=503, detail="Model not loaded yet")
    return {"status": "ok"}


@app.post("/predict")
def predict(msg: Message):
    if _model is None:
        raise HTTPException(status_code=503, detail="Model not loaded yet")
    label = _model.predict([msg.text])[0]
    return {"label": label}