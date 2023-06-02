:: https://www.dostips.com/forum/viewtopic.php?f=3&t=409
@echo off
Set filename="%~1"
For %%A in ("%filename%") do (
    Set Folder=%%~dpA
    Set Name=%%~nxA
)
:: echo.Folder is: %Folder%
:: echo.Name is: %Name%

python3 ../../AA2.py -i %Name%
pause