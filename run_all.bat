@echo off
echo ========================================================
echo Starting LLM-Viewer (Backend + Frontend)
echo ========================================================
start "LLM-Viewer Backend" cmd /k "call venv\Scripts\activate.bat && python backend_app.py --local"
start "LLM-Viewer Frontend" cmd /k "cd frontend && npm run dev"
echo Both servers started!
echo Frontend will be available at: http://localhost:5173/
echo Backend will be available at:  http://127.0.0.1:5000/
timeout /t 3 >nul
start http://localhost:5173/
