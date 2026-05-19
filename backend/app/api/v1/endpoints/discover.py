import logging
from fastapi import APIRouter, HTTPException, Depends, UploadFile, File, Form, status
from supabase import Client

from app.schemas.discover import DiscoverResponse, GradeLevel
from app.schemas.scan import SaveScanRequest, SaveScanResponse
from app.services.llm_service import generate_discovery_from_image
from app.services.gamification_service import save_user_discovery
from app.services.graph_service import save_skill_to_graph
from app.core.security import get_user_db_client
from app.core.security_utils import sign_quest_matches, verify_and_extract_matches

logger = logging.getLogger(__name__)
router = APIRouter()

MAX_FILE_SIZE = 5 * 1024 * 1024


@router.post("/vision", response_model=DiscoverResponse)
async def discover_from_vision(
    grade_level: GradeLevel = Form(..., description="The user's academic stage"),
    file: UploadFile = File(..., description="The photo taken by the user"),
    db_data: tuple[Client, str] = Depends(get_user_db_client),
):
    db_client, user_id = db_data
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=415, detail="Invalid file type.")
    if file.size and file.size > MAX_FILE_SIZE:
        raise HTTPException(status_code=413, detail="Image exceeds the 5MB limit.")

    try:
        image_bytes = await file.read()
        if len(image_bytes) > MAX_FILE_SIZE:
            raise HTTPException(status_code=413, detail="Image exceeds the 5MB limit.")

        # --- 1. Fetch Active Quests ---
        active_quests_context = ""
        quest_lens_map = {}  # Maps task_id -> target_strand

        # Simple, robust queries instead of complex deep joins
        enrollments = (
            db_client.table("user_pathways")
            .select("id, pathway_id, pathways(target_strand)")
            .eq("user_id", user_id)
            .eq("status", "active")
            .execute()
        )

        if enrollments.data:
            enrollment_ids = [e["id"] for e in enrollments.data]
            pathway_map = {
                e["id"]: e["pathways"]["target_strand"] for e in enrollments.data
            }

            tasks = (
                db_client.table("user_pathway_tasks")
                .select(
                    "task_id, user_pathway_id, pathway_tasks(ai_verification_prompt)"
                )
                .in_("user_pathway_id", enrollment_ids)
                .eq("is_completed", False)
                .execute()
            )

            if tasks.data:
                active_quests_context = "ACTIVE QUESTS TO VERIFY:\n"
                for t in tasks.data:
                    tid = t["task_id"]
                    strand = pathway_map.get(t["user_pathway_id"])
                    prompt = t["pathway_tasks"]["ai_verification_prompt"]
                    quest_lens_map[tid] = strand
                    active_quests_context += (
                        f"- Quest ID: {tid} | Condition: {prompt}\n"
                    )

        # --- 2. Call AI ---
        llm_resp = await generate_discovery_from_image(
            image_bytes, grade_level.value, active_quests_context
        )

        # --- 3. Process Gamification Tokens ---
        verified_matches = []
        target_lenses = set()

        for matched_id in llm_resp.matched_quest_ids:
            if matched_id in quest_lens_map:
                lens = quest_lens_map[matched_id]
                verified_matches.append({"id": matched_id, "lens": lens})
                target_lenses.add(lens)

        token = sign_quest_matches(verified_matches) if verified_matches else None

        # --- 4. NEW: Memory Pre-Check (Foreshadowing State) ---
        completed_lenses = []
        try:
            past_scans = (
                db_client.table("scans")
                .select("chosen_lens")
                .eq("user_id", user_id)
                .eq("object_name", llm_resp.scanned_object)
                .execute()
            )
            if past_scans.data:
                # Extract unique lenses they have already completed for this object
                completed_lenses = list(
                    set([scan["chosen_lens"] for scan in past_scans.data])
                )
        except Exception as mem_err:
            logger.error(f"Failed to fetch completed lenses: {mem_err}")
            # Non-fatal error, we just pass an empty list if it fails

        return DiscoverResponse(
            scanned_object=llm_resp.scanned_object,
            teaser_doors=llm_resp.teaser_doors,
            matched_quest_ids=[m["id"] for m in verified_matches],
            gamification_token=token,
            quest_target_lenses=list(target_lenses),
            completed_lenses=completed_lenses,  # 🚀 Pass it to the mobile UI
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected vision error: {e}")
        raise HTTPException(status_code=500, detail="An internal error occurred.")
    finally:
        await file.close()


@router.post("/save", response_model=SaveScanResponse)
async def save_discovery_choice(
    request: SaveScanRequest, db_data: tuple[Client, str] = Depends(get_user_db_client)
):
    db_client, user_id = db_data
    try:
        concept_card = request.learning_deck.get("concept_card", {})
        extracted_domain = concept_card.get("domain", "General Knowledge")
        extracted_skill = concept_card.get("skill", "General Skill")

        # Existing Save logic
        scan_id, final_xp = save_user_discovery(db_client, user_id, request)

        # Graph DB Save
        graph_success = await save_skill_to_graph(
            user_id=user_id,
            strand_name=request.chosen_lens,
            domain_name=extracted_domain,
            skill_name=extracted_skill,
            xp_awarded=final_xp,
        )
        if not graph_success:
            logger.warning(f"Failed to update Neo4j for user {user_id}.")

        # --- NEW: Pathway Quest Commit & Completion Check ---
        completed_quests = []
        if request.gamification_token:
            matches = verify_and_extract_matches(request.gamification_token)
            for match in matches:
                # ONLY grant completion if they picked the highlighted door!
                if match["lens"] == request.chosen_lens:
                    task_id = match["id"]

                    try:
                        # 🚀 USE THE ATOMIC POSTGRES RPC WE BUILT!
                        # This safely handles marking the task, checking for pathway completion,
                        # and awarding the bonus XP in a single database transaction.
                        rpc_res = db_client.rpc(
                            "complete_pathway_task",
                            {
                                "p_user_id": user_id,
                                "p_task_id": task_id,
                                "p_scan_id": str(scan_id),
                            },
                        ).execute()

                        result_data = rpc_res.data
                        if result_data and result_data.get("pathway_completed"):
                            completed_quests.append(task_id)
                            # Add the securely calculated DB points to the UI response
                            final_xp += result_data.get("points_awarded", 0)

                    except Exception as rpc_err:
                        logger.error(
                            f"Failed to process quest completion for task {task_id}: {rpc_err}"
                        )
                        # We log the error but do not raise an HTTPException so the base scan still saves successfully.

        # Create a dynamic success message
        msg = f"Action completed! {final_xp} XP added."
        if completed_quests:
            msg = f"QUEST COMPLETE! Massive bonus awarded! {final_xp} XP added."

        return SaveScanResponse(
            status="success",
            message=msg,
            scan_id=str(scan_id),
            xp_awarded=final_xp,
        )
    except Exception as e:
        logger.error(f"Save Discovery Error for user {user_id}: {e}")
        raise HTTPException(
            status_code=500, detail="Failed to save discovery progress."
        )
