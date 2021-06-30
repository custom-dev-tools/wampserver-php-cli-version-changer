@echo off
setlocal EnableDelayedExpansion EnableExtensions


rem +------------------------------------------------+
rem |            User Defined Variable(s)            |
rem +------------------------------------------------+

rem WampServer custom install path.
set $customInstallPath=



rem +------------------------------------------------+
rem |           DO NOT EDIT BELOW THIS LINE          |
rem +------------------------------------------------+

rem -------------------
rem  Default Variables
rem -------------------
set $scriptVersion=1.3.0

set $defaultInstallPath[0]=C:\wamp
set $defaultInstallPath[1]=C:\wamp64

set $pathToPhpFolders=bin\php

set $cliMode=0
set $cliSessionMode=0

set $colorNormal=08
set $colorSuccess=0A
set $colorWarning=0E
set $colorFailure=0C


rem ------------------
rem  Operation By CLI
rem ------------------

rem Check if the CLI is being used.
if "%1" neq "" (
    set $cliMode=1

    rem Check if the CLI session mode is being used.
    if "%2"=="-t" (
        set $cliSessionMode=1
    )

    if "%2"=="--temp" (
        set $cliSessionMode=1
    )
)


rem ------------------
rem  Operation by TUI
rem ------------------

rem Check if the TUI is being used.
if %$cliMode% equ 0 (
    cls
    title WampServer PHP CLI Version Changer v%$scriptVersion%
    color %$colorNormal%
)


rem ---------------
rem  Install Paths
rem ---------------

rem Test for a custom install path.
if defined $customInstallPath (

    rem Check if the folder exists.
    if not exist "%$customInstallPath%" goto invalidCustomInstallPathGiven

    set $installPath=%$customInstallPath%
)

rem Test for the first default install path.
if not defined $installPath (

    rem Check if the first default install path exists.
    if exist %$defaultInstallPath[0]% (
        set $installPath=%$defaultInstallPath[0]%
    )
)

rem Test for the second default install path.
if not defined $installPath (

    rem Check if the second default install path exists.
    if exist %$defaultInstallPath[1]% (
        set $installPath=%$defaultInstallPath[1]%
    )
)

rem Exit if unable to find installation path.
if not defined $installPath goto defaultInstallPathsMissing


rem -----------------
rem  PHP Folder Path
rem -----------------

rem Set the path to the PHP folders.
if %$installPath:~-1% neq \ (
    set $pathToPhpFolders=%$installPath%\%$pathToPhpFolders%
) else (
    set $pathToPhpFolders=%$installPath%%$pathToPhpFolders%
)

rem Check the path to the PHP folders exists.
if not exist "%$pathToPhpFolders%" goto invalidPathToPhpFoldersGiven

rem Iterate through the folders in the the $pathToPhpFolders variable adding them to the $availablePhpVersionsArray.
set counter=0

for /F "delims=" %%a in ('dir %$pathToPhpFolders% /AD /B') do (
    set /A counter=counter+1
    set $availablePhpVersionsArray[!counter!]=%%a
)

rem Set the last available PHP versions array id.
set $lastAvailablePhpVersionsArrayId=!counter!


rem --------------------------
rem  Users Environmental Path
rem --------------------------

rem Get the users environmental path string.
for /F "usebackq tokens=2,*" %%a in (`reg.exe query HKCU\Environment /v PATH`) do (
    set $usersEnvironmentalPathString=%%b
)

rem Using recursion, explode the users environmental path string into an array.
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


rem --------------------------
rem  Match PHP Folder Version
rem --------------------------

rem If there is more than one PHP path in the users environmental path, the operating system
rem will only use the first one. Therefore, we only need to match the first one.
set $currentPhpVersionId=0
set $currentUserEnvPathId=0

rem Iterate through the users environmental path array.
for /L %%a in (1,1,%$lastUsersEnvironmentalPathArrayId%) do (

    rem Iterate through the available PHP versions array.
    for /L %%b in (1,1,%$lastAvailablePhpVersionsArrayId%) do (

        rem Check if the users environmental path string matches the (combined) full path of the available PHP version string.
        if "!$usersEnvironmentalPathArray[%%a]!"=="%$pathToPhpFolders%\!$availablePhpVersionsArray[%%b]!" (
            rem Force the 'for' command parameters into type 'integer'.
            set /A $currentPhpVersionId=currentPhpVersionId+%%b
            set /A $currentUserEnvPathId=$currentUserEnvPathId+%%a
            goto break
        )
    )
)
:break


rem ------------------
rem  Operation By CLI
rem ------------------

rem Check if the CLI is being used.
if %$cliMode% equ 1 (

    rem Set the newly selected id.
    set $newSelectionId=0

    rem Iterate through the available PHP versions array.
    for /L %%a in (1,1,%$lastAvailablePhpVersionsArrayId%) do (

        rem If a matching installed PHP folder name is found, set the new selection id.
        if "%1"=="!$availablePhpVersionsArray[%%a]!" (
            set $newSelectionId=%%a
        )
    )

    rem Bypass displaying anything.
    goto checkUserInput
)


rem ---------
rem  Hack(s)
rem ---------

rem Hack to define a backspace so the 'set /p' command can be offset from the windows edge.
for /F %%a in ('"prompt $H &echo on &for %%b in (1) do rem"') do set backspace=%%a


rem ----------------------
rem  Display PHP Versions
rem ----------------------

rem Show the header.
echo:
echo   Available PHP CLI Versions
echo   --------------------------
echo:

rem Iterate though the available PHP versions array.
for /L %%a in (1,1,%$lastAvailablePhpVersionsArrayId%) do (

    rem Check if the listed version matches the current version.
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


rem ------------------
rem  Check User Input
rem ------------------
:checkUserInput

rem Check if the new selection comprises of digits.
echo %$newSelectionId%| findstr /R "^[1-9][0-9]*$" >nul
if %errorlevel% neq 0 goto invalidSelectionGiven

rem Check if the new selection is a valid selection.
if %$newSelectionId% gtr %$lastAvailablePhpVersionsArrayId% goto invalidSelectionGiven

rem Check if the new selection is the same as the current selection.
if %$newSelectionId% equ %$currentPhpVersionId% goto currentSelectionGiven


rem -------------------------------
rem  Update Users Environment Path
rem  TODO: Does this need to move down into is own block / function as well?
rem -------------------------------

rem Rebuild the users environmental path string excluding any and all previously
rem set PHP folder paths no matter where they are located within the string.
set "$usersEnvironmentalPathString="

rem Iterate through the users environmental path array.
for /L %%a in (1,1,%$lastUsersEnvironmentalPathArrayId%) do (

    rem Remove any trailing slash.
    if !$usersEnvironmentalPathArray[%%a]:~-1! equ \ (
        set $path=!$usersEnvironmentalPathArray[%%a]:~0,-1!
    ) else (
        set $path=!$usersEnvironmentalPathArray[%%a]!
    )

    rem Get the last segment of the path.
    for %%b in (!$path!) do (
        set $segment=%%~nxb
    )

    rem Check the segment for a matching regex expression. IE: Any PHP folder.
    echo !$segment! | findstr /R /C:"^php[1-9][0-9]*\.[0-9][0-9]*\.*[0-9]*[0-9]*" >nul

    rem If a match is not found, append the path to the users environmental path string.
    if !errorlevel! neq 0 (
        set $usersEnvironmentalPathString=!$usersEnvironmentalPathString!!$usersEnvironmentalPathArray[%%a]!;
    )
)

rem Add the selected PHP folder path to the end of the users environmental path string.
rem: TODO: move down into setx path code block.
set $usersEnvironmentalPathString=%$usersEnvironmentalPathString%%$pathToPhpFolders%\!$availablePhpVersionsArray[%$newSelectionId%]!


rem -----------------------------------------
rem  Perform action depending on entry point
rem -----------------------------------------

rem Check if the CLI session mode is being used.
if %$cliSessionMode% equ 1 (
    rem Get path (which is a combination of both the system environmental path and the user environmental path).


    rem Explode the path.
    call :explodeEnvironmentalPath

    rem Remove any existing PHP version references.
    call :implodeEnvironmentalPathExcludingPhps

    rem Add the selected PHP path.
    call :includeSelectedPhpPath

    rem Message must come first as we loose reference to new selection variable.
    call :sessionUpdateSuccessful

    rem Set the sessions environmental path variable.
    endlocal && set "Path=%$usersEnvironmentalPathString%" >nul

    exit /B 0
) else (
    rem Get the users environmental path.


    rem Explode the path.
    call :explodeEnvironmentalPath

    rem Remove any existing PHP version references.
    call :implodeEnvironmentalPathExcludingPhps

    rem Add the selected PHP path.
    call :includeSelectedPhpPath

    rem Set the user environmental path variable.
    setx path "%$usersEnvironmentalPathString%" >nul

    rem Show the successful message.
    goto updateSuccessful
)


rem ====================================================================================================================
rem                                                      Functions
rem ====================================================================================================================

rem Explode the environmental path string.
:explodeEnvironmentalPath

exit /B


rem ----------------------------
rem  Implode path excluding PHP
rem ----------------------------
:implodePathExcludingPhps

exit /B


rem ---------------------------
rem  Include selected PHP path
rem ---------------------------
:includeSelectedPhpPath

exit /B


rem ====================================================================================================================
rem                                               Success Message
rem ====================================================================================================================

rem -------------------
rem  Update successful
rem -------------------
:updateSuccessful

if %$cliMode% equ 0 (
    color %$colorSuccess%
    echo   Update Successful - The PHP CLI version is now !$availablePhpVersionsArray[%$newSelectionId%]!
    echo:
    echo   Press any key to exit.
    pause >nul
    exit 0
) else (
    echo Success - The PHP CLI version is now !$availablePhpVersionsArray[%$newSelectionId%]!
    exit /B 0
)


rem ---------------------------
rem  Session update successful
rem ---------------------------
:sessionUpdateSuccessful

echo Success: This sessions PHP CLI version is now !$availablePhpVersionsArray[%$newSelectionId%]!

exit /B


rem ====================================================================================================================
rem                                               Notice Message
rem ====================================================================================================================

rem -------------------------
rem  Current selection given
rem -------------------------
:currentSelectionGiven

if %$cliMode% equ 0 (
    color %$colorSuccess%
    echo   Current selection was given - The PHP CLI version remains unchanged.
    echo:
    echo   Press any key to exit.
    pause >nul
    exit 0
) else (
    echo Notice: The PHP CLI version remains unchanged.
    exit /B 0
)


rem ====================================================================================================================
rem                                               Failure Message
rem ====================================================================================================================

rem -------------------------
rem  Invalid selection given
rem -------------------------
:invalidSelectionGiven

if %$cliMode% equ 0 (
    color %$colorWarning%
    echo   An invalid selection was given - The PHP CLI version remains unchanged.
    echo:
    echo   Press any key to exit.
    pause >nul
    exit 1
) else (
    echo Failure: An invalid php version was given - The PHP CLI version remains unchanged.
    exit /B 1
)


rem ====================================================================================================================
rem                                                Error Messages
rem ====================================================================================================================

rem -----------------------------------
rem  Invalid custom install path given
rem -----------------------------------
:invalidCustomInstallPathGiven

if %$cliMode% equ 0 (
    color %$colorFailure%
    echo:
    echo   The $customInstallPath path "%$customInstallPath%" does not exist.
    echo:
    echo   Press any key to exit.
    pause >nul
    exit 1
) else (
    echo Error: The $customInstallPath path "%$customInstallPath%" does not exist.
    exit /B 1
)


rem -------------------------------
rem  Default install paths missing
rem -------------------------------
:defaultInstallPathsMissing
if %$cliMode% equ 0 (
    color %$colorFailure%
    echo:
    echo   Neither of the default installation paths exists.
    echo:
    echo    1. %$defaultInstallPath[0]%
    echo    2. %$defaultInstallPath[1]%
    echo:
    echo   WampServer does not appear to be installed.
    echo:
    echo   Press any key to exit.
    pause >nul
    exit 1
) else (
    echo Error: Neither of the default installation paths exists.
    echo         1. %$defaultInstallPath[0]%
    echo         2. %$defaultInstallPath[1]%
    echo        WampServer does not appear to be installed.
    exit /B 1
)


rem ----------------------------------
rem  Invalid path to PHP folder given
rem ----------------------------------
:invalidPathToPhpFoldersGiven

if %$cliMode% equ 0 (
    color %$colorFailure%
    echo:
    echo   The $pathToPhpFolders path "%$pathToPhpFolders%" does not exist.
    echo:
    echo   See the WampServer website for help.
    echo:
    echo   Press any key to exit.
    pause >nul
    exit 1
) else (
    echo Error: The $pathToPhpFolders path "%$pathToPhpFolders%" does not exist.
    echo        See the WampServer website for help.
    exit /B 1
)