from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.prompts import PromptTemplate
from app.core.config import settings
from app.schemas.discover import DiscoverResponse, DiscoverRequest

# Initialize LLM with the safely loaded API key
llm = ChatGoogleGenerativeAI(
    model="gemini-2.5-flash",
    google_api_key=settings.GEMINI_API_KEY,
    temperature=0.7
)

# Bind our Pydantic model directly to the LLM to guarantee strict JSON output
structured_llm = llm.with_structured_output(DiscoverResponse)

prompt_template = PromptTemplate.from_template(
    "You are a Filipino educational guide. The user scanned a '{scanned_object}' "
    "and is in the '{grade_level}' academic stage. Generate 4 culturally-relevant "
    "'Teaser Doors' representing the STEM, ABM, HUMSS, and TVL academic strands "
    "based on this object, tailored specifically to the comprehension level of a {grade_level} student."
)


async def generate_discovery_cards(data: DiscoverRequest) -> DiscoverResponse:
    chain = prompt_template | structured_llm
    # We invoke the chain, which will return a validated DiscoverResponse Pydantic object
    result = await chain.ainvoke({
        "scanned_object": data.scanned_object,
        # Pass the explicit string value of the Enum
        "grade_level": data.grade_level.value
    })
    return result
