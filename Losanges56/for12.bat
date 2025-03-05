@echo off
for /f "tokens=*" %%g in ('dir /b /a-d') do (
	echo %%~nxag
)
