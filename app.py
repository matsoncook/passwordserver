from fastapi import FastAPI
from fastapi.responses import FileResponse
from pathlib import Path

# Initialize the FastAPI application
app = FastAPI(title="Static File Server")

# Define the path to your HTML file
# Path(__file__).parent gets the current directory where main.py is located
HTML_FILE_PATH = Path(__file__).parent / "index.html"
CRYPT_FILE_PATH = Path(__file__).parent / "crypt.html"

@app.get("/pass", summary="Serve the index.html page")
async def read_index():
    """
    Returns the content of the index.html file as an HTML response.
    """
    # Check if the file exists before attempting to serve it
    if not HTML_FILE_PATH.exists():
        return {"error": "index.html not found"}, 404
    
    # Use FileResponse to efficiently serve the file
    # media_type="text/html" ensures the browser renders it correctly
    return FileResponse(HTML_FILE_PATH, media_type="text/html")

@app.get("/crypt", summary="Serve the index.html page")
async def read_index():
    """
    Returns the content of the index.html file as an HTML response.
    """
    # Check if the file exists before attempting to serve it
    if not HTML_FILE_PATH.exists():
        return {"error": "index.html not found"}, 404
    
    # Use FileResponse to efficiently serve the file
    # media_type="text/html" ensures the browser renders it correctly
    return FileResponse(CRYPT_FILE_PATH, media_type="text/html")

# if __name__ == "__main__":
#     import uvicorn
#     uvicorn.run(app, host="0.0.0.0", port=8000)