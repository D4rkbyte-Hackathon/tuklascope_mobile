import logging
from supabase import Client

logger = logging.getLogger(__name__)


def _skill_web_has_scan_activity(skill_web: dict) -> bool:
    xp_distribution = skill_web.get("xp_distribution") or {}
    if any(int(v or 0) > 0 for v in xp_distribution.values()):
        return True
    return bool(skill_web.get("top_skills"))


def fetch_compass_skill_web_fallback(
    db_client: Client, user_id: str
) -> dict | None:
    """
    Builds a pathfinder-compatible payload from compass_results when the user
    has not scanned objects yet.
    """
    try:
        response = (
            db_client.table("compass_results")
            .select("stem_affinity, abm_affinity, humss_affinity, tvl_affinity")
            .eq("user_id", user_id)
            .maybe_single()
            .execute()
        )
        row = response.data
        if not row:
            return None

        stem = int(row.get("stem_affinity") or 0)
        abm = int(row.get("abm_affinity") or 0)
        humss = int(row.get("humss_affinity") or 0)
        tvl = int(row.get("tvl_affinity") or 0)

        if stem + abm + humss + tvl <= 0:
            return None

        return {
            "xp_distribution": {
                "stem": stem,
                "abm": abm,
                "humss": humss,
                "tvl": tvl,
            },
            "top_skills": [],
            "data_source": "compass",
        }
    except Exception as e:
        logger.error(f"Failed to fetch compass fallback for user {user_id}: {e}")
        return None


def resolve_pathfinder_input(
    db_client: Client, user_id: str, skill_web: dict | None
) -> tuple[dict, bool]:
    """
    Returns (skill_web_payload, from_compass).
    Prefers Neo4j scan data; falls back to Compass when there is no scan activity.
    """
    if skill_web and _skill_web_has_scan_activity(skill_web):
        return skill_web, False

    compass_web = fetch_compass_skill_web_fallback(db_client, user_id)
    if compass_web:
        return compass_web, True

    raise ValueError("no_pathfinder_data")
