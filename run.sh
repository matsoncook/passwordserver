#!/usr/bin/env bash

source /home/ubuntu/cryptoserver/venv/bin/activate

uvicorn app:app --host 0.0.0.0 --port 8042 
