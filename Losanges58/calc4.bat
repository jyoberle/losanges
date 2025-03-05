@echo off
set /a operande=25
call :calcul %operande% 1 2 3 4
goto :eof

:calcul
set /a somme=0
for %%x in (%*) do set /a somme+=%%x
echo %somme%
exit /b