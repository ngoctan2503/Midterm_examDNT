@echo off
REM Khoi dong REST API (Node.js/Express) cong 3000
cd /d "%~dp0server"
if not exist node_modules call npm install
call npm start
