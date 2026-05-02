![Tuklascope Logo](mobile/assets/images/Tuklascope-readme.png)

Tuklascope is an AI-powered educational mobile application designed to democratize learning and spark continuous, interdisciplinary curiosity among Filipino youth. By transforming any student's everyday environment into an interactive classroom, the app makes complex concepts across sciences, arts, business, and practical skills highly accessible and culturally relevant. Built to provide personalized education and career guidance by putting a culturally-aware mentor in the pocket of every Filipino student...

## Features

- **The Spark:** An interdisciplinary scanner that uses real-world object identification to generate tailored learning cards for STEM, ABM, HUMSS, and TVL strands.
- **Kaalaman Skill Tree:** A dynamic, expansive network graph that visually represents a user's holistic learning progress based on their autonomous choices.
- **Pathfinder AI:** A rule-based AI engine providing personalized K-12 academic tracking, college degree, and career guidance.
- **Conversational AI Tutor:** An on-demand chatbot that answers follow-up questions contextually with a culturally relevant, age-appropriate tone.
- **Gamified Engagement:** Daily themed quests (Tuklas-Araw) and competitive leaderboards to build continuous learning habits.

## Tech Stack

| Layer            | Technology                                      | Purpose / Usage                                                                 |
| ---------------- | ----------------------------------------------- | ------------------------------------------------------------------------------- |
| Frontend         | [Flutter](https://flutter.dev/)                 | Open-source UI software development kit for smooth cross-platform mobile apps   |
|                  | [Dart](https://dart.dev/)                       | Core programming language for the Flutter framework                             |
|                  | Riverpod / Provider                             | Robust state management to handle complex UI rendering without memory leaks     |
| Backend          | [FastAPI](https://fastapi.tiangolo.com/)        | High-performance Python framework for building asynchronous APIs                |
|                  | [Python](https://www.python.org/)               | Core language for backend orchestrator and AI routing logic                     |
| AI & ML          | Google Gemini 2.5 Flash                         | Engine for multimodal vision and educational content generation                 |
|                  | LangChain                                       | Framework for AI prompt orchestration and hallucination safety                  |
| Database         | [Supabase](https://supabase.com/)               | PostgreSQL backend for authentication, relational data, and user XP             |
|                  | Neo4j AuraDB                                    | Graph database utilized to map and render the Kaalaman Skill Tree               |
|                  | Qdrant / Pinecone                               | Vector database to power the context-aware Conversational AI Tutor              |

## Prerequisites

| Category         | Tool / Technology         | Purpose / Notes / Installation                                   |
| ---------------- | ------------------------- | ---------------------------------------------------------------- |
| System           | Windows 10+ / Android 15+ | Windows 10+ for development, Android physical device for testing.|
| Mobile SDK       | Flutter SDK               | Required to run and build the mobile application.                |
| Python           | Python 3.11+              | Core language for backend and AI integration.                    |
| Package Manager  | pip                       | Python package manager.                                          |
| Python Env       | venv / virtualenv         | Isolated Python environment for backend dependencies.            |
| Mobile Testing   | Android Device            | Physical device connected via USB debugging for camera tests.    |

## Developer Profiles

- **John Michael A. Nave** << Project Manager | Frontend Developer >>
  [![github](https://img.shields.io/badge/github-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Goldenavs)

- **James Andrew S. Ologuin** << Frontend Designer >>
  [![github](https://img.shields.io/badge/github-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/OJamesAndrew)

- **John Peter D. Pestaño** << Backend Developer >>
  [![github](https://img.shields.io/badge/github-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/FloatingDust36)

- **Jordan A. Cabandon** << Backend Developer >>
  [![github](https://img.shields.io/badge/github-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/cabandonjordan)

- **John Zachary N. Gillana** << Backend Developer >>
  [![github](https://img.shields.io/badge/github-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/jzekken)
