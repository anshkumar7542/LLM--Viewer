@echo off
echo Starting LLM-Viewer Flask Backend on http://127.0.0.1:5000 ...
call venv\Scripts\activate.bat
python backend_app.py --local
pause
