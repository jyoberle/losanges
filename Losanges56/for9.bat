@echo off
for /f "tokens=1-3" %%g in (pi.txt) do (
	echo %%g %%h %%i
)