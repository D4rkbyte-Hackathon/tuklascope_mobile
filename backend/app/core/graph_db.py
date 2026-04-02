from neo4j import GraphDatabase, Driver
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)


class Neo4jConnection:
    def __init__(self):
        self.driver: Driver | None = None
        self.connect()

    def connect(self):
        if not settings.NEO4J_URI or not settings.NEO4J_PASSWORD:
            logger.warning(
                "Neo4j credentials missing. Graph features will be disabled.")
            return

        try:
            # Initialize the driver with basic routing and connection pooling
            self.driver = GraphDatabase.driver(
                settings.NEO4J_URI,
                auth=(settings.NEO4J_USERNAME, settings.NEO4J_PASSWORD)
            )
            # Verify connectivity
            self.driver.verify_connectivity()
            logger.info("Successfully connected to Neo4j AuraDB!")
        except Exception as e:
            logger.error(f"Failed to connect to Neo4j: {str(e)}")
            self.driver = None

    def close(self):
        if self.driver:
            self.driver.close()


# Instantiate globally
neo4j_db = Neo4jConnection()
