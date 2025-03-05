@echo off
cls
set /a adeviner=%random% * 100 / 32768 + 1
echo J'ai choisi un nombre entre 1 et 100. A vous de le deviner !
:Rep
set nombre=
set /p nombre=Veuillez specifiez un nombre entre 1 et 100 : 
if "%nombre%"=="" goto :Rep
set /a valeur=%nombre%
if %valeur% LSS 1 goto Rep
if %valeur% GTR 100 goto Rep

if %valeur% LSS %adeviner% (
echo C'est plus grand
goto :Rep
)

if %valeur% GTR %adeviner% (
echo C'est plus petit
goto :Rep
)

echo Bravo, vous avez trouve ! C'etait bien %adeviner%