@echo off
for /f "tokens=1-2 delims=," %%g in (pi.txt) do (
	echo %%h %%g
)