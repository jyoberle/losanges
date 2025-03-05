@echo off
setlocal enabledelayedexpansion

rem controle des arguments
if "%1"=="" goto erreur
if "%2"=="" goto erreur
set /a m=%1
set /a y=%2
if %m% LSS 1 goto erreur
if %m% GTR 12 goto erreur
if %y% LSS 1 goto erreur

rem on considere le premier jour du mois pour la formule
set /a d=1
rem nombre de jours par mois
set nj[1]=31
set nj[2]=28
set nj[3]=31
set nj[4]=30
set nj[5]=31
set nj[6]=30
set nj[7]=31
set nj[8]=31
set nj[9]=30
set nj[10]=31
set nj[11]=30
set nj[12]=31
rem par defaut, pas une annee bissextile
set /a bis=0

rem determination du nombre de jours du mois (en tenant compte des annees bissextiles)
if %m% EQU 2 (
	set /a div4=%y%%%4
	set /a div100=%y%%%100
	set /a div400=%y%%%400
	
	if %y% LSS 1583 (
		rem calendrier julien
		if !div4! EQU 0 (set /a bis=1)
	) else (
		rem calendrier gregorien
		if !div4! EQU 0 if !div100! NEQ 0 (set /a bis=1)
		if !div400! EQU 0 (set /a bis=1)
	)
)
	
set /a nbj=!nj[%m%]! + %bis%

rem calcul du premier jour du mois
set /a d1=(23*%m%/9+%d%+4+%y%+(%y%-1)/4-(%y%-1)/100+(%y%-1)/400)%%7
set /a d2=(23*%m%/9+%d%+2+%y%+%y%/4-%y%/100+%y%/400)%%7
if %m% LSS 3 (set /a d=%d1%) else (set /a d=%d2%)

rem ecriture du mois et de l'annee
echo Mois %m% - Annee %y%

rem ecriture des jours de la semaine
echo|set /p="D  L  M  M  J  V  S " 

rem retour chariot
echo.

rem ecriture des elements vides (sous forme de points)
for /l %%g in (1,1,%d%) do (
	echo|set /p=".  "
)

rem ecriture des jours du mois
for /l %%g in (1,1,%nbj%) do (
	set /a j=%%g + %d% - 1
	set /a k=!j! %% 7
	if !j! NEQ 0 if !k! EQU 0 (echo.)
	if %%g LSS 10 (echo|set /p="%%g  ") else (echo|set /p="%%g ")
)

endlocal
exit /b 0

:erreur
echo cal.bat mois (1 a 12) annee (a partir de 1)
endlocal
exit /b 5