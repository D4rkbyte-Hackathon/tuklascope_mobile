# Tuklascope Developer Guide 🚀

Welcome to the Tuklascope engineering team! We are using a **Monorepo** structure. [cite_start]This means both our Flutter Mobile App and our Python API Backend live in this single repository[cite: 59]. 

This guide will help you set up your local environment in under 10 minutes so you can start shipping features.

## 🏗️ Repository Architecture

Our code is split into two isolated workspaces:

* `/mobile`: Contains the Flutter (Dart) frontend application. [cite_start]All UI, state management (Riverpod/Provider), and camera logic live here[cite: 10, 21].
* `/backend`: Contains the Python (FastAPI) backend. [cite_start]This acts as the Orchestrator, handling AI prompts via LangChain and communicating with our databases[cite: 24, 26, 38].

---

## 💻 1. Setting up the Frontend (Flutter)

If you are working on the mobile UI, follow these steps. [cite_start]We strictly use **Visual Studio Code (VS Code)** to save system memory, testing directly on physical Android phones via USB Debugging rather than heavy virtual emulators[cite: 17, 19].

**Prerequisites:** Ensure you have the Flutter SDK installed on your machine.

1.  Open your terminal and navigate to the mobile workspace:
    ```bash
    cd mobile
    ```
2.  Install all Dart/Flutter dependencies:
    ```bash
    flutter pub get
    ```
3.  Set up your local environment variables:
    * Copy the `.env.example` file and rename it to `.env`.
    * Ask the Tech Lead for the local development keys. **NEVER commit your `.env` file to Git.**
4.  Run the app on your connected device:
    ```bash
    flutter run
    ```

---

## ⚙️ 2. Setting up the Backend (Python)

If you are working on the API, AI integrations, or database logic, follow these steps.

**Prerequisites:** Ensure you have Python 3.10+ installed.

1.  Open your terminal and navigate to the backend workspace:
    ```bash
    cd backend
    ```
2.  Create a virtual environment to isolate your dependencies:
    ```bash
    # Windows (Git Bash)
    python -m venv venv
    source venv/Scripts/activate
    
    # Mac/Linux
    python3 -m venv venv
    source venv/bin/activate
    ```
    *(You should see `(venv)` in your terminal prompt now).*
3.  Install the required Python packages:
    ```bash
    pip install -r requirements.txt
    ```
4.  Set up your local environment variables:
    * Copy the `.env.example` file and rename it to `.env`.
    * Add your Gemini API Key and database credentials.
5.  Start the development server:
    ```bash
    uvicorn app.main:app --reload
    ```
    The API is now running at `http://127.0.0.1:8000`. You can view the interactive documentation at `http://127.0.0.1:8000/docs`.

---

## 🌿 Git Workflow & Best Practices

[cite_start]To prevent us from overwriting each other's work[cite: 59]:

1.  **Never push directly to `main`.**
2.  Always create a new branch for your feature or fix. 
    * Format: `feature/name-of-feature` or `bugfix/issue-description`
3.  Run the backend and frontend locally to ensure your changes don't break the existing application before opening a Pull Request.
4.  **Important:** Because we are in a monorepo, always ensure your terminal is in the correct directory (`/mobile` or `/backend`) before running commands!