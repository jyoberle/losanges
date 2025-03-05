@echo off
call :calcul 1 2 3 4 5 6 7 8 9 10
call :calcul 1 2 3 4 5
goto :eof

:calcul
set /a somme=0
for %%x in (%*) do set /a somme+=%%x
echo %somme%
exit /b

