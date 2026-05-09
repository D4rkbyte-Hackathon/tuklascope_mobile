import hmac
import hashlib
import json
import base64
from typing import List, Dict
from app.core.config import settings


def sign_quest_matches(matches: List[Dict[str, str]]) -> str:
    """
    Creates a signed token for quest matches.
    Format of matches: [{"id": "uuid", "lens": "STEM"}]
    """
    if not matches:
        return ""

    payload = json.dumps({"matches": matches}).encode("utf-8")
    encoded_payload = base64.urlsafe_b64encode(payload).decode("utf-8")

    signature = hmac.new(
        settings.GEMINI_API_KEY.encode(),  # Using API key as a secure, existing secret
        encoded_payload.encode(),
        hashlib.sha256,
    ).hexdigest()

    return f"{encoded_payload}.{signature}"


def verify_and_extract_matches(token: str) -> List[Dict[str, str]]:
    """Verifies token signature and returns the list of matches."""
    if not token or "." not in token:
        return []

    try:
        encoded_payload, signature = token.split(".", 1)
        expected_signature = hmac.new(
            settings.GEMINI_API_KEY.encode(), encoded_payload.encode(), hashlib.sha256
        ).hexdigest()

        if not hmac.compare_digest(signature, expected_signature):
            return []  # Token was tampered with!

        payload = json.loads(base64.urlsafe_b64decode(encoded_payload).decode("utf-8"))
        return payload.get("matches", [])
    except Exception:
        return []
