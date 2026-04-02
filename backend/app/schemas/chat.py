from pydantic import BaseModel, Field


class ChatMessage(BaseModel):
    role: str = Field(..., description="Must be 'user' or 'assistant'")
    content: str = Field(..., description="The content of the message")


class ChatRequest(BaseModel):
    message: str = Field(..., description="The user's current question")
    history: list[ChatMessage] = Field(
        default=[],
        description="Array of previous messages to provide context to the AI"
    )


class ChatResponse(BaseModel):
    reply: str = Field(..., description="The AI Tutor's response")
