@echo off
setlocal
cls
:Rep1
set annee=
set /p reponse=Quelle est ton annee de naissance ? 
if "%reponse%"=="" goto :Rep1
set /a annee=%reponse%
:Rep2
set mois=
set /p reponse=Quel est ton mois de naissance (de 1 a 12) ? 
if "%reponse%"=="" goto :Rep2
set /a mois=%reponse%

call cal.bat %mois% %annee%
echo.

if %ERRORLEVEL% GTR 0 (
	echo Tu as mal renseigne soit ton annee soit ton mois de naissance. Reessaie !
) else (
	echo Tu peux maintenant trouver le jour de ta naissance
)

endlocal
exit /b 0
