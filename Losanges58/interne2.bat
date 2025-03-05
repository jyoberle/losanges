 @echo off
 setlocal enabledelayedexpansion
 set variable1=bonjour
 set variable2=variable1
 set resultat=!%variable2%!
 echo %resultat%
 endlocal