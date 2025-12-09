from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import nacl.signing
import hashlib

app = FastAPI()

# Allow frontend (any origin for demo)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class SeedRequest(BaseModel):
    seed: str

@app.post("/generate")
def generate_keys(req: SeedRequest):
    seed_bytes = hashlib.sha256(req.seed.encode()).digest()
    signing_key = nacl.signing.SigningKey(seed_bytes)
    verify_key = signing_key.verify_key

    return {
        "private_key": signing_key.encode().hex(),
        "public_key": verify_key.encode().hex()
    }
