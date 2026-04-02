import base64
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.messages import HumanMessage
from app.core.config import settings
from app.schemas.discover import DiscoverResponse, DiscoverRequest
from fastapi import HTTPException

# Initialize LLM with the safely loaded API key
llm = ChatGoogleGenerativeAI(
    model="gemini-2.5-flash",
    google_api_key=settings.GEMINI_API_KEY,
    temperature=0.7
)

# Bind our Pydantic model directly to the LLM to guarantee strict JSON output
structured_llm = llm.with_structured_output(DiscoverResponse)

# Past text-based function for fallback/testing purposes


async def generate_discovery_cards(data: DiscoverRequest) -> DiscoverResponse:
    prompt_text = (
        f"You are a Filipino educational guide. The user scanned a '{data.scanned_object}' "
        f"and is in the '{data.grade_level.value}' academic stage. Generate 4 culturally-relevant "
        "'Teaser Doors' representing the STEM, ABM, HUMSS, and TVL academic strands "
        f"based on this object, tailored specifically to a {data.grade_level.value} student."
    )
    result = await structured_llm.ainvoke(prompt_text)
    return result


async def generate_discovery_from_image(image_bytes: bytes, grade_level: str) -> DiscoverResponse:
    try:
        # 1. Encode the image bytes to base64 so LangChain can securely transport it
        image_b64 = base64.b64encode(image_bytes).decode("utf-8")

        # 2. Craft the Multimodal prompt
        prompt_text = (
            f"You are a Filipino educational guide. The user is in the '{grade_level}' academic stage. "
            "Look at the uploaded image and identify the primary object. Then, generate 4 culturally-relevant "
            "'Teaser Doors' representing the STEM, ABM, HUMSS, and TVL academic strands based on that specific object, "
            f"tailored to the comprehension level of a {grade_level} student. "
            "Accurately fill in the 'scanned_object' field with the name of the object you identified."
        )

        # 3. Assemble the HumanMessage with both text and image
        message = HumanMessage(
            content=[
                {"type": "text", "text": prompt_text},
                {
                    "type": "image_url",
                    "image_url": {"url": f"data:image/jpeg;base64,{image_b64}"}
                }
            ]
        )

        # 4. Invoke the model and force the structured JSON output
        result = await structured_llm.ainvoke([message])
        return result
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"AI Vision Processing Failed: {str(e)}")
