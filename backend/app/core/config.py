from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    PROJECT_NAME: str = "Tuklascope API"
    API_V1_STR: str = "/api/v1"
    GEMINI_API_KEY: str

    # Database Keys (Allowing them to be optional for now since we are just doing AI)
    SUPABASE_URL: str | None = None
    SUPABASE_ANON_KEY: str | None = None

    # Vector Database Keys
    QDRANT_URL: str | None = None
    QDRANT_API_KEY: str | None = None

    # Allows loading from .env file for local development
    # extra="ignore" tells Pydantic not to crash if it finds other unexpected variables in the .env
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )


# Instantiate globally so it can be imported anywhere safely
settings = Settings()
