@echo off
set /a a=0
for /l %%g in (1,1,5) do (
	set /a a=%a%+1
)
echo %a%