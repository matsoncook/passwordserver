from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from pydantic import BaseModel
import hashlib
import nacl.signing
from Crypto.PublicKey import RSA
from pathlib import Path

# Initialize the FastAPI application
app = FastAPI(title="Static File Server")

# Base directories for static content
BASE_DIR = Path(__file__).parent
WWWROOT = BASE_DIR / "wwwroot"

# Static file paths
LOGIN_PAGE = WWWROOT / "index.html"
CRYPT_PAGE = WWWROOT / "crypt" / "index.html"
KEYGEN_PAGE = WWWROOT / "keygen.html"


class SeedRequest(BaseModel):
    seed: str


@app.get("/pass", summary="Serve the index.html page")
async def serve_login():
    """Serve the login page."""
    if not LOGIN_PAGE.exists():
        return {"error": "index.html not found"}, 404
    return FileResponse(LOGIN_PAGE, media_type="text/html")

@app.get("/crypt", summary="Serve the index.html page")
async def serve_hash_tool():
    """Serve the browser hash calculator page."""
    if not CRYPT_PAGE.exists():
        return {"error": "crypt page not found"}, 404
    return FileResponse(CRYPT_PAGE, media_type="text/html")


@app.get("/keys", summary="Serve the deterministic key generator page")
async def serve_keygen():
    """Serve the deterministic public/private key generator page."""
    if not KEYGEN_PAGE.exists():
        return {"error": "keygen page not found"}, 404
    return FileResponse(KEYGEN_PAGE, media_type="text/html")

@app.get("/keygen.html", summary="Serve the deterministic key generator page (direct link)")
async def serve_keygen_html():
    """Serve the deterministic public/private key generator page for direct file hits."""
    if not KEYGEN_PAGE.exists():
        return {"error": "keygen page not found"}, 404
    return FileResponse(KEYGEN_PAGE, media_type="text/html")


@app.post("/api/generate-keys")
async def generate_keys(payload: SeedRequest):
    """
    Deterministically generate a public/private key pair from a seed.
    The seed is hashed with SHA-256 to derive a 32-byte seed for PyNaCl.
    """
    seed_value = payload.seed.strip()
    if not seed_value:
        raise HTTPException(status_code=400, detail="Seed cannot be empty.")

    seed_bytes = hashlib.sha256(seed_value.encode()).digest()
    signing_key = nacl.signing.SigningKey(seed_bytes)
    verify_key = signing_key.verify_key

    return {
        "private_key": signing_key.encode().hex(),
        "public_key": verify_key.encode().hex(),
    }


def _deterministic_randfunc(seed: bytes):
    """
    Create a deterministic randfunc for RSA generation using SHA-256(counter || seed).
    This makes RSA key generation reproducible for a given seed.
    """
    counter = 0

    def randfunc(n: int) -> bytes:
        nonlocal counter
        output = b""
        while len(output) < n:
            counter += 1
            output += hashlib.sha256(seed + counter.to_bytes(8, "big")).digest()
        return output[:n]

    return randfunc


@app.post("/api/generate-rsa")
async def generate_rsa(payload: SeedRequest):
    """
    Deterministically generate an RSA 2048 key pair from a seed using a seeded PRNG.
    Returns PEM-encoded keys.
    """
    seed_value = payload.seed.strip()
    if not seed_value:
        raise HTTPException(status_code=400, detail="Seed cannot be empty.")

    seed_bytes = hashlib.sha256(seed_value.encode()).digest()
    randfunc = _deterministic_randfunc(seed_bytes)
    rsa_key = RSA.generate(2048, randfunc=randfunc)
    private_pem = rsa_key.export_key(format="PEM").decode()
    public_pem = rsa_key.publickey().export_key(format="PEM").decode()

    return {
        "private_key": private_pem,
        "public_key": public_pem,
    }

# if __name__ == "__main__":
#     import uvicorn
#     uvicorn.run(app, host="0.0.0.0", port=8000)
