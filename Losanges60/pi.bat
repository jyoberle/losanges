@echo off
setlocal
call :pi1
endlocal
goto :eof

:pi1
echo | set /p="3" 
call :pi2
goto :eof
:pi2
echo | set /p=","
call :pi3
goto :eof
:pi3
echo | set /p="1"
call :pi4
goto :eof
:pi4
echo 4
goto :eof
