# backend/app/services/llm_service.py
import base64
import asyncio
from fastapi import HTTPException, status
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.messages import HumanMessage
from app.core.config import settings
from app.core.prompts import (
    VISION_DISCOVERY_PROMPT,
    LEARNING_DECK_PROMPT,
    PATHFINDER_PROMPT,
    PATHFINDER_COMPASS_PROMPT,
)
from app.schemas.discover import DiscoverLLMResponse
from app.schemas.pathfinder import PathfinderResponse
from app.schemas.cards import LearningDeckResponse

# ==========================================
# 1. GLOBAL LLM INITIALIZATION
# ==========================================
llm = ChatGoogleGenerativeAI(
    model="gemini-2.5-flash",
    google_api_key=settings.GEMINI_API_KEY,
    temperature=0.7,
    max_retries=2,  # Built-in retry logic for brief network hiccups
)

structured_discover = llm.with_structured_output(DiscoverLLMResponse)
structured_pathfinder = llm.with_structured_output(PathfinderResponse)
structured_deck = llm.with_structured_output(LearningDeckResponse)

# We reduced timeout from 45s to 25s. If Gemini takes longer than 25s for Flash,
# it's usually hanging. Better to fail fast and let the user retry.
LLM_TIMEOUT = 25.0

# ==========================================
# 2. SERVICE FUNCTIONS
# ==========================================


async def generate_discovery_from_image(
    image_bytes: bytes, grade_level: str, active_quests_context: str = ""
) -> DiscoverLLMResponse:
    try:
        image_b64 = base64.b64encode(image_bytes).decode("utf-8")
        prompt_text = VISION_DISCOVERY_PROMPT.format(
            grade_level=grade_level, active_quests_context=active_quests_context
        )

        message = HumanMessage(
            content=[
                {"type": "text", "text": prompt_text},
                {
                    "type": "image_url",
                    "image_url": {"url": f"data:image/jpeg;base64,{image_b64}"},
                },
            ]
        )

        return await asyncio.wait_for(
            structured_discover.ainvoke([message]), timeout=LLM_TIMEOUT
        )

    except asyncio.TimeoutError:
        raise HTTPException(
            status_code=status.HTTP_504_GATEWAY_TIMEOUT,
            detail="Vision AI timed out while analyzing the image. The network might be slow.",
        )
    except Exception as e:
        error_str = str(e)

        # 1. Handle Rate Limits
        if "429" in error_str or "RESOURCE_EXHAUSTED" in error_str:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Scanner network congested. Please wait a few seconds and try scanning again.",
            )

        # 2. Handle Inappropriate Objects (NSFW, Violence, etc.)
        if "SAFETY" in error_str or "FinishReason.SAFETY" in error_str:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="System Override: Unidentified or Restricted Anomaly Detected. Scan Aborted.",
            )

        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"AI Vision Processing Failed: {error_str}",
        )


async def generate_holistic_pathfinder(
    xp_distribution: dict,
    top_skills: list | dict,
    *,
    from_compass: bool = False,
) -> PathfinderResponse:
    try:
        template = PATHFINDER_COMPASS_PROMPT if from_compass else PATHFINDER_PROMPT
        prompt_text = template.format(
            xp_distribution=xp_distribution,
            top_skills=top_skills if not from_compass else [],
        )
        return await asyncio.wait_for(
            structured_pathfinder.ainvoke(prompt_text), timeout=LLM_TIMEOUT
        )

    except asyncio.TimeoutError:
        raise HTTPException(
            status_code=status.HTTP_504_GATEWAY_TIMEOUT,
            detail="Pathfinder AI timed out. Please try again.",
        )
    except Exception as e:
        error_str = str(e)

        # 1. Handle Rate Limits
        if "429" in error_str or "RESOURCE_EXHAUSTED" in error_str:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Pathfinder generation is currently queued. Please try again in a moment.",
            )

        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"Pathfinder generation failed: {error_str}",
        )


async def generate_learning_deck(
    object_name: str,
    strand: str,
    grade_level: str,
    teaser_context: str,
    existing_skills: list[str],
) -> LearningDeckResponse:
    try:
        prompt_text = LEARNING_DECK_PROMPT.format(
            grade_level=grade_level,
            object_name=object_name,
            strand=strand,
            teaser_context=teaser_context,
            existing_skills=existing_skills,
        )
        return await asyncio.wait_for(
            structured_deck.ainvoke(prompt_text), timeout=LLM_TIMEOUT
        )

    except asyncio.TimeoutError:
        raise HTTPException(
            status_code=status.HTTP_504_GATEWAY_TIMEOUT,
            detail="Learning Deck AI timed out generating the lesson. Please try again.",
        )
    except Exception as e:
        error_str = str(e)
        if "429" in error_str or "RESOURCE_EXHAUSTED" in error_str:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Tuklascope AI is currently analyzing too many anomalies globally. Please wait a few seconds and try again.",
            )
        # Handle Safety blocks in the future here
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"Learning Deck AI Failed: {error_str}",
        )
