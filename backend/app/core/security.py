from fastapi import Depends, HTTPException, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from supabase import create_client, Client
from app.core.config import settings

security = HTTPBearer()


def get_user_db_client(credentials: HTTPAuthorizationCredentials = Security(security)) -> tuple[Client, str]:
    """
    Validates the Flutter JWT.
    Returns a tuple containing: (Authenticated Supabase Client, The User's ID)
    This ensures all database interactions strictly obey the Row Level Security (RLS) policies.
    """
    token = credentials.credentials

    # Create a fresh client for this specific request
    client = create_client(settings.SUPABASE_URL, settings.SUPABASE_ANON_KEY)

    try:
        # Inject the user's token into the client headers
        client.postgrest.auth(token)

        # Verify the token is valid by fetching the user
        user_response = client.auth.get_user(token)
        if not user_response.user:
            raise HTTPException(
                status_code=401, detail="Invalid or expired authentication token")

        # Return both the client AND the explicitly extracted user ID
        return client, user_response.user.id
    except Exception as e:
        raise HTTPException(
            status_code=401, detail=f"Authentication failed: {str(e)}")
