import logging
from app.core.graph_db import neo4j_db

logger = logging.getLogger(__name__)


async def get_existing_skills_for_strand(strand_name: str) -> list[str]:
    """
    Fetches all existing Skills under a specific Strand.
    We pass this to the AI so it reuses existing nodes instead of creating 100 variations of the same skill.
    """
    if not neo4j_db.driver:
        return []

    query = """
    MATCH (s:Strand {name: $strand_name})<-[:FALLS_UNDER]-(d:Domain)<-[:BELONGS_TO]-(k:Skill)
    RETURN k.name AS skill_name LIMIT 30
    """
    try:
        records, _, _ = await neo4j_db.driver.execute_query(
            query, strand_name=strand_name.upper()
        )
        return [record["skill_name"] for record in records]
    except Exception as e:
        logger.error(f"Failed to fetch existing skills: {str(e)}")
        return []


async def get_user_skill_web(user_id: str) -> dict | None:
    """
    Builds the user's complete RPG profile directly from the Graph DB.
    Returns their Strand XP distribution and their highest-leveled Skills as structured JSON.
    """
    if not neo4j_db.driver:
        logger.error("Neo4j driver not initialized.")
        return None

    # Query 1: Base Classes (Strands)
    xp_query = """
    MATCH (u:User {id: $user_id})-[e:EXPLORED]->(s:Strand)
    RETURN s.name AS strand, e.total_xp AS xp
    """

    # Query 2: Mastered Skills with Aggregated Domains
    # A single skill can belong to multiple domains, so we collect them into an array.
    skills_query = """
    MATCH (u:User {id: $user_id})-[m:MASTERED]->(k:Skill)
    OPTIONAL MATCH (k)-[:BELONGS_TO]->(d:Domain)-[:FALLS_UNDER]->(s:Strand)
    RETURN k.name AS skill_name, 
           collect(DISTINCT d.name) AS domains, 
           collect(DISTINCT s.name) AS strands, 
           m.level AS level, 
           m.total_xp AS xp
    ORDER BY level DESC, xp DESC LIMIT 12
    """

    try:
        xp_records, _, _ = await neo4j_db.driver.execute_query(
            xp_query, user_id=user_id
        )
        skill_records, _, _ = await neo4j_db.driver.execute_query(
            skills_query, user_id=user_id
        )

        if not xp_records and not skill_records:
            return None

        # Format Strand distribution cleanly (e.g., {"stem": 1400, "abm": 50})
        xp_distribution = {record["strand"].lower(): record["xp"] for record in xp_records}

        # Build strict JSON objects, eliminating frontend Regex parsing
        top_skills = []
        for rec in skill_records:
            strands = rec["strands"]
            # Default to the first strand found, or fallback to 'stem' if detached
            primary_strand = strands[0].lower() if strands else "stem"
            
            top_skills.append({
                "skill_name": rec["skill_name"],
                "domains": rec["domains"],  # Now a proper array: ["Physics", "Computer Science"]
                "strand": primary_strand,
                "level": rec["level"],
                "xp": rec["xp"]
            })

        return {
            "xp_distribution": xp_distribution, 
            "top_skills": top_skills
        }
        
    except Exception as e:
        logger.error(f"Failed to fetch Skill Web from Neo4j: {str(e)}")
        return None


async def save_skill_to_graph(
    user_id: str, strand_name: str, domain_name: str, skill_name: str, xp_awarded: int
) -> bool:
    """
    The core RPG Engine.
    Builds the Strand <- Domain <- Skill hierarchy and awards the user XP/Levels across the chain.
    """
    if not neo4j_db.driver:
        return False

    query = """
    // 1. Ensure User and Base Strand exist
    MERGE (u:User {id: $user_id})
    MERGE (s:Strand {name: $strand_name})

    // 2. Ensure Domain exists and belongs to the Strand
    MERGE (d:Domain {name: $domain_name})
    MERGE (d)-[:FALLS_UNDER]->(s)

    // 3. Ensure Skill exists and belongs to the Domain
    MERGE (k:Skill {name: $skill_name})
    MERGE (k)-[:BELONGS_TO]->(d)

    // 4. Award XP to the Strand Edge
    MERGE (u)-[e:EXPLORED]->(s)
    ON CREATE SET e.total_xp = $xp_awarded
    ON MATCH SET e.total_xp = e.total_xp + $xp_awarded

    // 5. Award XP to the Domain Edge
    MERGE (u)-[std:STUDIED]->(d)
    ON CREATE SET std.total_xp = $xp_awarded
    ON MATCH SET std.total_xp = std.total_xp + $xp_awarded

    // 6. Level Up the specific Skill Edge
    MERGE (u)-[m:MASTERED]->(k)
    ON CREATE SET m.level = 1, m.total_xp = $xp_awarded
    ON MATCH SET m.level = m.level + 1, m.total_xp = m.total_xp + $xp_awarded
    
    RETURN u, s, d, k
    """

    try:
        await neo4j_db.driver.execute_query(
            query,
            user_id=user_id,
            strand_name=strand_name.upper(),
            domain_name=domain_name,
            skill_name=skill_name,
            xp_awarded=xp_awarded,
        )
        return True
    except Exception as e:
        logger.error(f"Failed to graph skill to Neo4j: {str(e)}")
        return False
