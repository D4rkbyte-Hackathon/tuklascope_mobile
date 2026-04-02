from app.api import gemini
from fastapi import FastAPI
from dotenv import load_dotenv
import os

# 1. WE MUST LOAD THE .ENV FILE BEFORE DOING ANYTHING ELSE
load_dotenv()

# 2. NOW WE CAN IMPORT THE AI ROUTE

# 3. INITIALIZE THE APP
app = FastAPI(
    title="Tuklascope Backend API",
    description="AI-Powered Holistic Discovery Application Orchestrator",
    version="1.0.0"
)

app.include_router(gemini.router, prefix="/api", tags=["AI Discovery"])


@app.get("/")
async def root():
    return {"status": "ok", "message": "Tuklascope API is running!"}
