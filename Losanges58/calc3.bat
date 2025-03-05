@echo off
set /a somme1=0
set /a somme2=0
set /a resultat=0
call :addition somme1 1 2 3 4
call :addition somme2 5 6 7 8
call :multiplication resultat %somme1% %somme2%
echo %somme1%
echo %somme2%
echo %resultat%
goto :eof

:addition
set /a %1=%2 + %3 + %4 + %5
exit /b

:multiplication
set /a %1=%2 * %3
exit /b