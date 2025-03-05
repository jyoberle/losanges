@echo off
for /r %%g in (*) do (	
	if %%~zg gtr 1000000 (
		echo %%g taille : %%~zg octets
	)
)