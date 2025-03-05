@echo off
setlocal
set /a resultat = 1
call :Fibonacci resultat 0 20
echo %resultat%
endlocal
goto :eof

:Fibonacci
set /a nombre1=%1
set /a nombre2=%2
set /a compteur=%3-1
set /a nombreN=%nombre1% + %nombre2%
if %compteur% GTR 1 call :Fibonacci nombreN %nombre1% compteur
set %1=%nombreN%
goto :eof
