@echo off
cls
setlocal EnableDelayedExpansion EnableExtensions
mode con: cols=75 lines=40


rem +------------------------------------------------+
rem |            User Defined Variable(s)            |
rem +------------------------------------------------+

rem WampServer install path.
set $pathToInstall=C:\wamp



rem +------------------------------------------------+
rem |           DO NOT EDIT BELOW THIS LINE          |
rem +------------------------------------------------+

rem ---------------------
rem   Default Variables
rem ---------------------
set $scriptVersion=1.0.0

set $pathToPhps=bin\php\

set $cliMode=0

set $colorNormal=08
set $colorSuccess=0A
set $colorWarning=0E
set $colorFailure=0C


rem ----------------------------
rem   Users Environmental Path
rem ----------------------------

rem Get the users environmental path string.
for /f "usebackq tokens=2,*" %%a in (`reg.exe query HKCU\Environment /v PATH`) do (
    set $usersEnvironmentalPathString=%%b
)

rem Explode the users environmental path string into an array.
set counter=0

:explode
for /F "tokens=1* delims=;" %%a in ("%$usersEnvironmentalPathString%") do (
    set /A counter=counter+1
    set $usersEnvironmentalPathArray[!counter!]=%%a
    set $usersEnvironmentalPathString=%%b
)

if defined $usersEnvironmentalPathString goto explode

rem Set the last users environmental path array id.
set $lastUsersEnvironmentalPathArrayId=!counter!


rem ---------------------------------
rem   Available PHP Folder Versions
rem ---------------------------------

rem Set the $pathToPhps path.
if %$pathToInstall:~-1% neq \ (
    set $pathToPhps=%$pathToInstall%\%$pathToPhps%
) else (
    set $pathToPhps=%$pathToInstall%%$pathToPhps%
)

rem Check the $pathToPhps path exists.
PUSHD %$pathToPhps% && POPD || (
    goto invalidPathToPhpsGiven
)

rem Iterate through folders in the the $pathToPhps path adding them to the availablePhpVersionsArray.
set counter=0

for /F "delims=" %%a in ('dir %$pathToPhps% /AD /B') do (
    set /A counter=counter+1
    set $availablePhpVersionsArray[!counter!]=%%a
)

rem Set the last available PHP versions array id.
set $lastAvailablePhpVersionsArrayId=!counter!


rem ----------------------------
rem   Match PHP Folder Version
rem ----------------------------

rem Only the first PHP path is used by the computer if more than one PHP path be detected in the users
rem environmental path. Therefore, there is no need to detect multiple PHP paths, only the first one.
set $currentPhpVersionId=0
set $currentUserEnvPathId=0

rem Loop through the $usersEnvironmentalPathArray.
for /L %%a in (1,1,%$lastUsersEnvironmentalPathArrayId%) do (
    rem Loop through the $availablePhpVersionsArray.
    for /L %%b in (1,1,%$lastAvailablePhpVersionsArrayId%) do (
        rem Check if the users environmental path string matches the path to the available PHP version string.
        if "!$usersEnvironmentalPathArray[%%a]!"=="%$pathToPhps%!$availablePhpVersionsArray[%%b]!" (
            rem Force the 'for' command parameters into type 'integer'.
            set /A $currentPhpVersionId=currentPhpVersionId+%%b
            set /A $currentUserEnvPathId=$currentUserEnvPathId+%%a
            goto break
        )
    )
)
:break


rem --------------------
rem   Operation By CLI
rem --------------------

rem Check if the CLI is being used.
if "%~1" neq "" (

    rem Set the CLI mode flag.
    set $cliMode=1
    set $newSelectionId=0

    rem Find the $newSelectionId by matching the name to the id.
    for /L %%a in (1,1,%$lastAvailablePhpVersionsArrayId%) do (
        if "%1"=="!$availablePhpVersionsArray[%%a]!" (
            set $newSelectionId=%%a
        )
    )

    rem Bypass displaying anything.
    goto checkUserInput
)


rem -----------
rem   Hack(s)
rem -----------

rem Hack to define a backspace so the 'set /p' command can be offset from the windows edge.
for /f %%a in ('"prompt $H &echo on &for %%b in (1) do rem"') do set backspace=%%a


rem ------------------------
rem   Display PHP Versions
rem ------------------------

rem Set the window.
title WampServer PHP CLI Version Changer v%$scriptVersion%
color %$colorNormal%


rem Show the title.
echo:
echo   Available PHP CLI Versions
echo   --------------------------
echo:

rem Display all available list of PHP folder names.
for /L %%a in (1,1,%$lastAvailablePhpVersionsArrayId%) do (
    if %%a equ %$currentPhpVersionId% (
        echo   %%a - !$availablePhpVersionsArray[%%a]! - Current
    ) else (
        echo   %%a - !$availablePhpVersionsArray[%%a]!
    )
)

rem Prompt the user to make a new selection.
echo:
set /p $newSelectionId=%backspace%  Selection (1-%$lastAvailablePhpVersionsArrayId%): 
echo:


rem --------------------
rem   Check User Input
rem --------------------
:checkUserInput

rem Check if the new selection comprises of digits.
echo %$newSelectionId%| findstr /r "^[1-9][0-9]*$">nul
if %errorlevel% neq 0 goto invalidSelectionGiven

rem Check if the new selection is a valid selection.
if %$newSelectionId% gtr %$lastAvailablePhpVersionsArrayId% goto invalidSelectionGiven

rem Check if the new selection is the same as the current selection.
if %$newSelectionId% equ %$currentPhpVersionId% goto currentSelectionGiven


rem ---------------------------------
rem   Update Users Environment Path
rem ---------------------------------

rem Rebuild the $usersEnvironmentalPathString excluding any previously set PHP folder path.
set "$usersEnvironmentalPathString="

for /L %%a in (1,1,%$lastUsersEnvironmentalPathArrayId%) do (
    if !$currentUserEnvPathId! neq %%a (
        set $result=!$result!!$usersEnvironmentalPathArray[%%a]!;
    )
)

rem Add the selected PHP folder path to the end of the $usersEnvironmentalPathString.
set $result=%$result%%$pathToPhps%!$availablePhpVersionsArray[%$newSelectionId%]!

rem Set the $usersEnvironmentalPathString.
setx path "%$result%" >nul


rem --------------------
rem   Exit Subroutines
rem --------------------

rem The update was successful.
:updateSuccessful

if %$cliMode% equ 0 (
    color %$colorSuccess%
    echo   Update Successful - The PHP CLI version is now !$availablePhpVersionsArray[%$newSelectionId%]!
    echo:
    echo   Press any key to exit.
    pause >nul
)

exit 0

rem A current selection was given.
:currentSelectionGiven

if %$cliMode% equ 0 (
    color %$colorSuccess%
    echo   Current selection was given - The PHP CLI version remains unchanged.
    echo:
    echo   Press any key to exit.
    pause >nul
)

exit 0

rem An invalid selection was given.
:invalidSelectionGiven

if %$cliMode% equ 0 (
    color %$colorWarning%
    echo   An invalid selection was given - The PHP CLI version remains unchanged.
    echo:
    echo   Press any key to exit.
    pause >nul
)

exit 1

rem An invalid $pathToPhps was given.
:invalidPathToPhpsGiven

if %$cliMode% equ 0 (
    color %$colorFailure%
    echo:
    echo   The $pathToPhps path "%$pathToPhps%" does not exist.
    echo:
    echo   See the WampServer website for help.
    echo:
    echo   Press any key to exit.
    pause >nul
)

exit 1