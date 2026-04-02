from app.core.graph_db import neo4j_db
import logging

logger = logging.getLogger(__name__)


def update_skill_tree(user_id: str, object_name: str, chosen_lens: str, xp_awarded: int):
    """
    Draws the user's discovery path in Neo4j.
    Uses MERGE to prevent duplicate nodes and build an interconnected web.
    """
    if not neo4j_db.driver:
        logger.warning("Graph DB not connected. Skipping skill tree update.")
        return

    # The Cypher Query: Drawing the map
    query = """
    // 1. Find or create the core nodes
    MERGE (u:User {id: $user_id})
    MERGE (o:Object {name: $object_name})
    MERGE (s:Strand {name: $chosen_lens})
    
    // 2. Draw the relationships between them
    MERGE (u)-[:SCANNED]->(o)
    MERGE (o)-[:BELONGS_TO]->(s)
    
    // 3. Track how many times the user explores this specific strand
    MERGE (u)-[e:EXPLORED]->(s)
    ON CREATE SET e.count = 1, e.total_xp = $xp_awarded
    ON MATCH SET e.count = e.count + 1, e.total_xp = e.total_xp + $xp_awarded
    """

    try:
        neo4j_db.driver.execute_query(
            query,
            user_id=user_id,
            object_name=object_name.strip().title(),  # Standardize formatting
            chosen_lens=chosen_lens.strip().upper(),
            xp_awarded=xp_awarded
        )
        logger.info(
            f"Successfully mapped {object_name} to the Kaalaman Skill Tree for user {user_id}")
    except Exception as e:
        # We don't want a graph failure to crash the whole API, so we just log it.
        logger.error(f"Failed to update Neo4j Skill Tree: {str(e)}")
