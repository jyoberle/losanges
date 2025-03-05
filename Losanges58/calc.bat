@echo off
call :calcul 1 2 3 4
call :calcul 5 6 7 8
goto :eof

:calcul
set /a somme=%1 + %2 + %3 + %4
echo %somme%
exit /b

