@echo off
for %%g in (for1.bat,for2.bat,"je n'existe pas") do (
	echo %%g
)