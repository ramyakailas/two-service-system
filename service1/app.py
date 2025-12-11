"""
Service 1: API Service
Exposes an endpoint that retrieves a string from Service 2
"""
from fastapi import FastAPI, HTTPException
import os
import requests

app = FastAPI(title="API Service")

DOWNSTREAM_URL = os.getenv("DOWNSTREAM_URL", "http://service2:8001/api/message")


@app.get("/api/string")
def get_string():
    try:
        resp = requests.get(DOWNSTREAM_URL, timeout=2.0)
        resp.raise_for_status()
    except requests.RequestException as e:
        raise HTTPException(status_code=502, detail=f"Error calling data service: {e}")

    try:
        payload = resp.json()
    except ValueError:
        raise HTTPException(status_code=500, detail="Invalid JSON from data service")

    message = payload.get("message")
    if message is None:
        raise HTTPException(status_code=500, detail="Data service response missing 'message'")

    return {"result": message}
