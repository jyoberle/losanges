 @echo off
 setlocal
 set variable1=bonjour
 set variable2=variable1
 call set resultat=%%%variable2%%%
 echo %resultat%
 endlocal