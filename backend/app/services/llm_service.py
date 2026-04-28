# backend/app/services/llm_service.py
import base64
import asyncio
from fastapi import HTTPException, status
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.messages import HumanMessage
from app.core.config import settings
from app.core.prompts import (
    VISION_DISCOVERY_PROMPT,
    TEXT_DISCOVERY_PROMPT,
    LEARNING_DECK_PROMPT,
    PATHFINDER_PROMPT,
)
from app.schemas.discover import DiscoverResponse, DiscoverRequest
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

structured_discover = llm.with_structured_output(DiscoverResponse)
structured_pathfinder = llm.with_structured_output(PathfinderResponse)
structured_deck = llm.with_structured_output(LearningDeckResponse)

# We reduced timeout from 45s to 25s. If Gemini takes longer than 25s for Flash,
# it's usually hanging. Better to fail fast and let the user retry.
LLM_TIMEOUT = 25.0

# ==========================================
# 2. SERVICE FUNCTIONS
# ==========================================


async def generate_discovery_from_image(
    image_bytes: bytes, grade_level: str
) -> DiscoverResponse:
    try:
        image_b64 = base64.b64encode(image_bytes).decode("utf-8")
        prompt_text = VISION_DISCOVERY_PROMPT.format(grade_level=grade_level)

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
            detail="Vision AI timed out while analyzing the image. The image might be too complex or the network is slow.",
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"AI Vision Processing Failed: {str(e)}",
        )


async def generate_holistic_pathfinder(
    xp_distribution: dict, top_skills: dict
) -> PathfinderResponse:
    try:
        prompt_text = PATHFINDER_PROMPT.format(
            xp_distribution=xp_distribution, top_skills=top_skills
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
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"Pathfinder generation failed: {str(e)}",
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
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"Learning Deck AI Failed: {str(e)}",
        )
