@echo off
set /a somme=0
call :calcul somme 1 2 3 4
echo %somme%
goto :eof

:calcul
shift
for %%x in (%*) do set /a %0+=%%x
exit /b
