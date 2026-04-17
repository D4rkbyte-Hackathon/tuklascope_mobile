# backend/app/core/security.py
from fastapi import Depends, HTTPException, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from supabase import create_client, Client
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)
security = HTTPBearer()


def get_user_db_client(credentials: HTTPAuthorizationCredentials = Security(security)) -> tuple[Client, str]:
    token = credentials.credentials

    try:
        # 1. Initialize a blank Supabase client
        client = create_client(settings.SUPABASE_URL,
                               settings.SUPABASE_ANON_KEY)

        # 2. 🚀 The Magic Bullet: Let Supabase natively verify the token
        # This automatically handles ALL algorithms, expirations, and security checks.
        auth_response = client.auth.get_user(token)

        if not auth_response or not auth_response.user:
            raise HTTPException(
                status_code=401, detail="User not found or token invalid.")

        user_id = auth_response.user.id

        # 3. Inject the token into the client so Row Level Security (RLS) works for database saves
        client.postgrest.auth(token)

        return client, user_id

    except Exception as e:
        logger.error(f"Authentication failed: {str(e)}")
        raise HTTPException(
            status_code=401, detail="Invalid or expired authentication token."
        )
