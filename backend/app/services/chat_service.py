from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.messages import HumanMessage, AIMessage, SystemMessage
from app.core.config import settings
from app.schemas.chat import ChatRequest
from fastapi import HTTPException

# Initialize the conversational model
llm = ChatGoogleGenerativeAI(
    model="gemini-2.5-flash",
    google_api_key=settings.GEMINI_API_KEY,
    temperature=0.4  # Slightly lower temperature for more factual, tutor-like responses
)


async def generate_tutor_response(data: ChatRequest) -> str:
    try:
        # 1. Establish the core persona
        messages = [
            SystemMessage(content=(
                "You are the Tuklascope AI Tutor. You are a friendly, culturally-aware "
                "Filipino educational guide. Answer questions accurately based on the K-12 "
                "DepEd curriculum. If a student is confused, explain concepts simply, clearly, "
                "and directly. Use a supportive and encouraging tone."
            ))
        ]

        # 2. Rebuild the conversation history for context
        for msg in data.history:
            if msg.role == "user":
                messages.append(HumanMessage(content=msg.content))
            else:
                messages.append(AIMessage(content=msg.content))

        # 3. Append the brand new question
        messages.append(HumanMessage(content=data.message))

        # 4. Invoke the model
        response = await llm.ainvoke(messages)

        return response.content

    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Tutor AI Processing Error: {str(e)}")
