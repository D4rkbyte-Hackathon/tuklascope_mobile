from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.prompts import PromptTemplate
from dotenv import load_dotenv
import os

# 1. Force load the .env file locally before doing anything else
load_dotenv()

router = APIRouter()


class ScanRequest(BaseModel):
    object_name: str
    age_group: str = "JHS"


# 2. Explicitly grab the key from the environment
google_api_key = os.getenv("GEMINI_API_KEY")

# 3. Explicitly pass the key to the model
llm = ChatGoogleGenerativeAI(
    model="gemini-2.5-flash",
    temperature=0.7,
    api_key=google_api_key
)


@router.post("/discover")
async def generate_teaser_doors(request: ScanRequest):
    try:
        prompt = PromptTemplate.from_template(
            "You are the Tuklascope AI Tutor. The user has scanned a: {object_name}. "
            "They are a Filipino student in the {age_group} age group. "
            "Generate 4 short, engaging 'Teaser Doors' explaining this object through the lenses of "
            "STEM, ABM, HUMSS, and TVL. Keep the context culturally relevant to the Philippines."
        )

        chain = prompt | llm
        response = chain.invoke({
            "object_name": request.object_name,
            "age_group": request.age_group
        })

        return {
            "target_object": request.object_name,
            "ai_response": response.content
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
