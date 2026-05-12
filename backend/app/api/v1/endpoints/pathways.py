import logging
from fastapi import APIRouter, Depends, HTTPException, status
from supabase import Client
from app.core.security import get_user_db_client
from app.schemas.pathways import (
    PathwayCatalogResponse,
    PathwaySchema,
    PathwayTaskSchema,
    PathwayStatus,
)

logger = logging.getLogger(__name__)
router = APIRouter()


@router.get("/catalog", response_model=PathwayCatalogResponse)
async def get_pathway_catalog(
    db_data: tuple[Client, str] = Depends(get_user_db_client),
):
    db_client, user_id = db_data
    try:
        # 1. Fetch all pathways and their underlying tasks in a single query
        catalog_res = (
            db_client.table("pathways")
            .select("*, pathway_tasks(id, task_description, order_index)")
            .execute()
        )

        # 2. Fetch the user's specific progress state
        user_state_res = (
            db_client.table("user_pathways")
            .select("pathway_id, status, user_pathway_tasks(task_id, is_completed)")
            .eq("user_id", user_id)
            .execute()
        )

        # 3. Map user state for O(1) memory lookups
        user_enrollments = {
            row["pathway_id"]: {
                "status": row["status"],
                "tasks": {
                    t["task_id"]: t["is_completed"]
                    for t in row.get("user_pathway_tasks", [])
                },
            }
            for row in user_state_res.data
        }

        pathways_list = []
        total_points_earned = 0
        active_count = 0
        total_progress_sum = 0

        for p in catalog_res.data:
            p_id = p["id"]
            u_state = user_enrollments.get(
                p_id, {"status": PathwayStatus.AVAILABLE.value, "tasks": {}}
            )

            status_val = u_state["status"]

            # Sort tasks safely by order_index
            raw_tasks = sorted(
                p.get("pathway_tasks", []), key=lambda x: x.get("order_index", 0)
            )

            mapped_tasks = []
            completed_tasks = 0

            for rt in raw_tasks:
                is_done = u_state["tasks"].get(rt["id"], False)
                if is_done:
                    completed_tasks += 1
                mapped_tasks.append(
                    PathwayTaskSchema(
                        id=rt["id"],
                        description=rt["task_description"],
                        is_completed=is_done,
                    )
                )

            # Calculate dynamic progress
            task_count = len(mapped_tasks)
            progress_pct = (
                int((completed_tasks / task_count * 100)) if task_count > 0 else 0
            )

            if status_val == PathwayStatus.ACTIVE.value:
                active_count += 1
                total_progress_sum += progress_pct
            elif status_val == PathwayStatus.COMPLETED.value:
                total_points_earned += p.get("total_points", 0)

            pathways_list.append(
                PathwaySchema(
                    id=p_id,
                    title=p["title"],
                    description=p["description"],
                    image_url=p["image_url"],
                    difficulty=p["difficulty"],
                    total_points=p.get("total_points", 0),
                    target_strand=p.get("target_strand", "GENERAL"),
                    status=status_val,
                    progress_percentage=progress_pct,
                    tasks=mapped_tasks,
                )
            )

        average_progress = (
            (total_progress_sum / active_count) if active_count > 0 else 0.0
        )

        return PathwayCatalogResponse(
            active_pathways_count=active_count,
            average_progress=round(average_progress, 1),
            total_points_earned=total_points_earned,
            pathways=pathways_list,
        )

    except Exception as e:
        logger.error(f"Catalog fetch failed for user {user_id}: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="Failed to load pathways catalog")


@router.post("/{pathway_id}/enroll")
async def enroll_in_pathway(
    pathway_id: str, db_data: tuple[Client, str] = Depends(get_user_db_client)
):
    db_client, user_id = db_data
    try:
        # Atomic Transaction execution via our Supabase RPC
        # This replaces 4 brittle REST calls with 1 perfectly safe transaction.
        res = db_client.rpc(
            "enroll_user_in_pathway", {"p_user_id": user_id, "p_pathway_id": pathway_id}
        ).execute()

        return res.data

    except Exception as e:
        error_message = str(e)
        logger.error(
            f"Failed to enroll in pathway {pathway_id}: {error_message}", exc_info=True
        )

        # Handle the specific exceptions raised from our PL/pgSQL function
        if (
            "already actively enrolled" in error_message
            or "already completed" in error_message
            or "attempted or abandoned" in error_message
        ):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=error_message.split("P0001: ")[
                    -1
                ],  # Extract just the message if wrapped by Postgres
            )

        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Enrollment failed due to server error.",
        )
