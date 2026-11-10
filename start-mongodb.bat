@echo off
REM Khoi dong MongoDB (ban portable) - 23IT.EB089 - Dang Ngoc Tan
REM Sua MONGOD neu ban cai MongoDB o vi tri khac
set MONGOD=D:\dev\mongodb\mongodb-win32-x86_64-windows-8.0.4\bin\mongod.exe
if not exist "%~dp0server\data\db" mkdir "%~dp0server\data\db"
"%MONGOD%" --dbpath "%~dp0server\data\db" --port 27017 --bind_ip 127.0.0.1
