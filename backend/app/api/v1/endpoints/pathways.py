import logging
from fastapi import APIRouter, Depends, HTTPException, status
from supabase import Client
from app.core.security import get_user_db_client
from app.schemas.pathways import (
    PathwayCatalogResponse,
    PathwaySchema,
    PathwayTaskSchema,
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
            u_state = user_enrollments.get(p_id, {"status": "available", "tasks": {}})

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

            if status_val == "active":
                active_count += 1
                total_progress_sum += progress_pct
            elif status_val == "completed":
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
        # 1. Ensure pathway exists and user isn't already enrolled
        existing = (
            db_client.table("user_pathways")
            .select("id")
            .eq("user_id", user_id)
            .eq("pathway_id", pathway_id)
            .execute()
        )
        if existing.data:
            raise HTTPException(
                status_code=400,
                detail="User is already enrolled or has abandoned this pathway.",
            )

        # 2. Create Enrollment
        enroll_res = (
            db_client.table("user_pathways")
            .insert({"user_id": user_id, "pathway_id": pathway_id, "status": "active"})
            .execute()
        )

        user_pathway_id = enroll_res.data[0]["id"]

        # 3. Fetch all tasks for this pathway
        tasks_res = (
            db_client.table("pathway_tasks")
            .select("id")
            .eq("pathway_id", pathway_id)
            .execute()
        )

        # 4. Create empty progress rows for each task so the tracker works immediately
        task_inserts = [
            {"user_id": user_id, "task_id": t["id"], "user_pathway_id": user_pathway_id}
            for t in tasks_res.data
        ]

        if task_inserts:
            db_client.table("user_pathway_tasks").insert(task_inserts).execute()

        return {"status": "success", "message": "Successfully enrolled in Pathway!"}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to enroll in pathway {pathway_id}: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="Enrollment failed.")
