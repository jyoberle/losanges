@echo off
set s=0 
for /l %%g in (1,1,5) do (
	set /a s=s+%%g
)
echo %s%

