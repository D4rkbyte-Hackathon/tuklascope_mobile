from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.v1.api_router import api_router
from app.core.database import supabase_db

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

# Crucial for Frontend integration!
app.add_middleware(
    CORSMiddleware,
    # Update this to specific origins (like the flutter web URL) in production
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix=settings.API_V1_STR)


@app.get("/health")
def health_check():
    return {"status": "ok", "message": "API is highly operational."}

# Database connection test route


@app.get("/health/db")
def db_health_check():
    try:
        # A simple ping to the auth service to check connectivity
        supabase_db.auth.get_session()
        return {"status": "ok", "message": "Successfully connected to Supabase!"}
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Database connection failed: {str(e)}")
