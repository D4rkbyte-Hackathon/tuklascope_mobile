from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    PROJECT_NAME: str = "Tuklascope API"
    API_V1_STR: str = "/api/v1"
    GEMINI_API_KEY: str

    # Security: CORS Allowed Origins
    # Defaulting to localhost for Flutter Web development
    ALLOWED_ORIGINS: list[str] = ["http://localhost:3000",
                                  "http://localhost:8080", "http://localhost:8000"]

    # Database Keys (Allowing them to be optional for now since we are just doing AI)
    SUPABASE_URL: str | None = None
    SUPABASE_ANON_KEY: str | None = None

    # Vector Database Keys
    QDRANT_URL: str | None = None
    QDRANT_API_KEY: str | None = None

    # Neo4j Graph Database Keys
    NEO4J_URI: str | None = None
    NEO4J_USERNAME: str | None = None
    NEO4J_PASSWORD: str | None = None

    # Allows loading from .env file for local development
    # extra="ignore" tells Pydantic not to crash if it finds other unexpected variables in the .env
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )


# Instantiate globally so it can be imported anywhere safely
settings = Settings()
