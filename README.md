# Tuklascope 🔍
**An Al-Powered Holistic Discovery Application**

## 📖 Abstract
Tuklascope is an Al-powered educational mobile application designed to democratize learning and spark continuous, interdisciplinary curiosity among Filipino youth. By transforming any student's everyday environment—from a rural farm to an urban street—into an interactive classroom, the app makes complex concepts across sciences, arts, business, and practical skills highly accessible and culturally relevant.

Our mission is to democratize access to personalized education and career guidance by putting an Al-powered, culturally-aware mentor in the pocket of every Filipino student.

## ✨ Core Features
Tuklascope utilizes a structured, gamified loop where Discovery feeds into Action, Action feeds into the Skill Tree, and the Skill Tree feeds into the Al's Guidance.

* **The "Spark" (Interdisciplinary Scanner):** Users scan everyday objects and choose an interdisciplinary "lens" (STEM, ABM, HUMSS, TVL) to explore the hidden science, history, or economics behind them.
* **The Continuum (Kaalaman Skill Tree):** A dynamic, expansive network graph that visually represents a user's unique progress based on their autonomous learning choices.
* **The Guide (Pathfinder AI):** A rule-based Al engine that analyzes the user's Kaalaman Skill Tree data over time to provide highly personalized, data-driven K-12 academic tracking, college degree, and career guidance.
* **The Tutor (Conversational AI):** An on-demand Al chatbot that answers follow-up questions contextually and in a culturally relevant, age-appropriate tone.

## 🎯 Target Audience
The application dynamically scales its vocabulary and content depth based on the user's developmental stage:
1.  **Elementary (Grades 1-6):** Focuses on sparking raw curiosity through play and sensory discovery.
2.  **Junior High School (Grades 7-10):** Focuses on deep exploration to help students make informed decisions about their Senior High School (SHS) tracks.
3.  **Senior High School (Grades 11-12):** Focuses on linking academic strands to real-world applications and specific career/college guidance.

## 🛠️ Technical Architecture & Stack
Given the constraints of a student-led project, this stack is strictly designed around robust, industry-standard tools utilizing Generous "Free Tiers".

* **Frontend:** Flutter (Dart) for smooth, 60fps cross-platform performance across budget Android and iOS devices.
* **Backend Orchestrator:** Python + FastAPI to handle asynchronous Al routing. Hosted on Render.
* **AI Engine:** Google Gemini API (via Google Al Studio) combined with LangChain for multimodal vision and text generation.
* **Multi-Database Architecture:** * *Relational/Auth:* Supabase (PostgreSQL).
    * *Graph DB:* Neo4j AuraDB (Maps the Kaalaman Skill Tree).
    * *Vector DB:* Qdrant or Pinecone (Powers the hallucination-free AI Tutor).