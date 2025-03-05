@echo off
call :affiche bonjour
call :affiche monde
goto :eof

:affiche
echo %1
exit /b

