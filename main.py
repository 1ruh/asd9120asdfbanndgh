"""
Glint License Key API - Render.com Deployment
Run: gunicorn main:app
"""

import os
import json
import uuid
import hashlib
import time
from datetime import datetime, timedelta
from fastapi import FastAPI, HTTPException, Header
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Optional
from pathlib import Path

app = FastAPI(title="Glint Key API")

# ============================
# CONFIG
# ============================

ADMIN_KEY = os.environ.get("GLINT_ADMIN_KEY", "CHANGE_THIS_TO_A_SECRET_STRING")
KEY_FILE = "keys.json"

# ============================
# KEY STORAGE
# ============================

def load_keys():
    if Path(KEY_FILE).exists():
        with open(KEY_FILE, "r") as f:
            return json.load(f)
    return {}

def save_keys(data):
    with open(KEY_FILE, "w") as f:
        json.dump(data, f, indent=2)

def generate_hwid_hash(hwid: str) -> str:
    return hashlib.sha256(f"glint_salt_{hwid}".encode()).hexdigest()[:16]

# ============================
# MODELS
# ============================

class GenerateKeyRequest(BaseModel):
    days: int = 7
    hwid: Optional[str] = None
    max_uses: int = 1

class ValidateKeyRequest(BaseModel):
    key: str
    hwid: str

class RevokeKeyRequest(BaseModel):
    key: str

# ============================
# ROUTES
# ============================

@app.get("/")
def root():
    return {"status": "ok", "service": "Glint Key API"}

@app.get("/health")
def health():
    return {"status": "healthy"}

@app.post("/api/generate")
def generate_key(req: GenerateKeyRequest, authorization: str = Header(None)):
    if authorization != f"Bearer {ADMIN_KEY}":
        raise HTTPException(status_code=401, detail="Invalid admin key")

    if req.days < 1 or req.days > 365:
        raise HTTPException(status_code=400, detail="Days must be between 1 and 365")

    key_id = uuid.uuid4().hex[:8].upper()
    key_secret = uuid.uuid4().hex[:12].upper()
    full_key = f"GLINT-{key_id}-{key_secret}"

    keys = load_keys()
    now = time.time()
    expires = now + (req.days * 86400)

    keys[full_key] = {
        "created": now,
        "expires": expires,
        "days": req.days,
        "hwid": generate_hwid_hash(req.hwid) if req.hwid else None,
        "max_uses": req.max_uses,
        "uses": 0,
        "revoked": False,
        "created_at": datetime.now().isoformat(),
        "expires_at": datetime.fromtimestamp(expires).isoformat(),
    }

    save_keys(keys)

    return {
        "key": full_key,
        "days": req.days,
        "expires_at": datetime.fromtimestamp(expires).isoformat(),
        "hwid_locked": req.hwid is not None,
    }

@app.post("/api/validate")
def validate_key(req: ValidateKeyRequest):
    keys = load_keys()
    key_data = keys.get(req.key)

    if not key_data:
        raise HTTPException(status_code=404, detail="Key not found")

    if key_data.get("revoked"):
        raise HTTPException(status_code=403, detail="Key has been revoked")

    if time.time() > key_data["expires"]:
        raise HTTPException(status_code=403, detail="Key has expired")

    hwid_hash = generate_hwid_hash(req.hwid)
    if key_data.get("hwid") and key_data["hwid"] != hwid_hash:
        raise HTTPException(status_code=403, detail="Key is bound to a different device")

    if not key_data.get("hwid"):
        key_data["hwid"] = hwid_hash
        save_keys(keys)

    if key_data["uses"] >= key_data["max_uses"]:
        raise HTTPException(status_code=403, detail="Key use limit reached")

    key_data["uses"] += 1
    key_data["last_used"] = datetime.now().isoformat()
    save_keys(keys)

    remaining = key_data["expires"] - time.time()

    return {
        "valid": True,
        "expires_in_seconds": int(remaining),
        "expires_at": datetime.fromtimestamp(key_data["expires"]).isoformat(),
    }

@app.post("/api/revoke")
def revoke_key(req: RevokeKeyRequest, authorization: str = Header(None)):
    if authorization != f"Bearer {ADMIN_KEY}":
        raise HTTPException(status_code=401, detail="Invalid admin key")

    keys = load_keys()
    if req.key not in keys:
        raise HTTPException(status_code=404, detail="Key not found")

    keys[req.key]["revoked"] = True
    save_keys(keys)

    return {"revoked": True, "key": req.key}

@app.get("/api/list")
def list_keys(authorization: str = Header(None)):
    if authorization != f"Bearer {ADMIN_KEY}":
        raise HTTPException(status_code=401, detail="Invalid admin key")

    keys = load_keys()
    result = []
    for k, v in keys.items():
        result.append({
            "key": k,
            "days": v["days"],
            "created_at": v.get("created_at", ""),
            "expires_at": v.get("expires_at", ""),
            "uses": v["uses"],
            "max_uses": v["max_uses"],
            "revoked": v["revoked"],
            "hwid_locked": v.get("hwid") is not None,
        })

    return {"keys": result, "total": len(result)}
