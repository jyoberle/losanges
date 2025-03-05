@echo off
for /f "tokens=1-5 delims=;" %%g in (pascal.csv) do (
	echo %%h %%i %%j
)