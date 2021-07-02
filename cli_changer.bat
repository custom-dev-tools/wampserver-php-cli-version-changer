@echo off
setlocal EnableDelayedExpansion EnableExtensions


rem +------------------------------------------------+
rem |            User Defined Variable(s)            |
rem +------------------------------------------------+

rem WampServer custom install path.
rem Note: Trailing slash is not required.
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


rem -------------------------
rem  Check Mode of Operation
rem -------------------------

rem Check mode of operation.
if "%1" neq "" (
    rem CLI Mode in use.
    set $cliMode=1

    rem Check if CLI session mode is in use.
    if "%2"=="-t" (
        set $cliSessionMode=1
    )

    if "%2"=="--temp" (
        set $cliSessionMode=1
    )
) else (
    rem TUI mode in use.
    cls
    title WampServer PHP CLI Version Changer v%$scriptVersion%
    color %$colorNormal%
)


rem --------------------------
rem  Check Installation Paths
rem --------------------------

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


rem -----------------------
rem  Check PHP Folder Path
rem -----------------------

rem Set the absolute path to the PHP folders.
if %$installPath:~-1% neq \ (
    set $pathToPhpFolders=%$installPath%\%$pathToPhpFolders%
) else (
    set $pathToPhpFolders=%$installPath%%$pathToPhpFolders%
)

rem Check the path to the PHP folders exists.
if not exist "%$pathToPhpFolders%" goto invalidPathToPhpFoldersGiven


rem ---------------------
rem  Get Available PHP's
rem ---------------------

rem Get a list of available PHP's.
set counter=0

for /F "delims=" %%a in ('dir %$pathToPhpFolders% /AD /B') do (
    set /A counter=counter+1
    set $availablePhpArray[!counter!]=%%a
)

rem Get the total number of elements in the available PHP array.
set $availablePhpCount=!counter!


rem ----------------------------
rem  Explode Environmental Path
rem ----------------------------

rem Get the correctly referenced environmental path.
if %$cliSessionMode% equ 0 (
    rem Get the 'users' environmental path.
    for /F "usebackq tokens=2,*" %%a in (`reg.exe query HKCU\Environment /v PATH`) do (
        set $pathString=%%b
)) else (
    rem Get the command window 'session' environmental path.
    rem Note: This path is a combination of the system environmental
    rem       path and the user environmental path.
    set $pathString=%Path%
)

rem Explode the path string into an array.
set counter=0

:explode
for /F "tokens=1* delims=;" %%a in ("%$pathString%") do (
    set /A counter=counter+1
    set $pathArray[!counter!]=%%a
    set $pathString=%%b
)

if defined $pathString goto explode

rem Get the total number of elements in the path array.
set $pathArrayCount=!counter!


rem ----------------------------
rem  Find Active PHP Version(s)
rem ----------------------------

rem As the operating system only uses the first found PHP reference in the environmental path, then we will as well.
rem Note: If a PHP version other than an installed version is found, it will not be shown as an option,
rem       though it will be removed from the environmental path when the newly selected version is added.
set $currentPhpVersionId=0

rem Iterate through the path array.
for /L %%a in (1,1,%$pathArrayCount%) do (

    rem Iterate through the available PHP's array.
    for /L %%b in (1,1,%$availablePhpCount%) do (

        rem Check if the path string matches the (combined) full path of the available PHP version string.
        if "!$pathArray[%%a]!"=="%$pathToPhpFolders%\!$availablePhpArray[%%b]!" (
            rem Force the 'for' command parameters into type 'integer'.
            set /A $currentPhpVersionId=currentPhpVersionId+%%b
            goto break
        )
    )
)

:break


rem ------------------
rem  Operation by CLI
rem ------------------

rem Check if the CLI is being used.
if %$cliMode% equ 1 (

    rem Set the newly selected id.
    set $newSelectionId=0

    rem Iterate through the available PHP versions array.
    for /L %%a in (1,1,%$availablePhpCount%) do (

        rem If a matching installed PHP folder name is found, set the new selection id.
        if "%1"=="!$availablePhpArray[%%a]!" (
            set $newSelectionId=%%a
        )
    )

    rem Bypass displaying the TUI.
    goto checkUserInput
)


rem ------------------
rem  Operation by TUI
rem ------------------

rem Hack to define a backspace so the 'set /p' command can be offset from the windows edge.
for /F %%a in ('"prompt $H &echo on &for %%b in (1) do rem"') do set backspace=%%a

rem Show the header.
echo:
echo   Available PHP CLI Versions
echo   --------------------------
echo:

rem Iterate though the available PHP versions array.
for /L %%a in (1,1,%$availablePhpCount%) do (

    rem Check if the listed version matches the current version.
    if %%a equ %$currentPhpVersionId% (
        echo   %%a - !$availablePhpArray[%%a]! - Current
    ) else (
        echo   %%a - !$availablePhpArray[%%a]!
    )
)

rem Prompt the user to make a selection.
echo:
set /p $newSelectionId=%backspace%  Selection (1-%$availablePhpCount%):
echo:


rem ------------------
rem  Check User Input
rem ------------------
:checkUserInput

rem Check if the new selection comprises of digits.
echo %$newSelectionId%| findstr /R "^[1-9][0-9]*$" >nul
if %errorlevel% neq 0 goto invalidSelectionGiven

rem Check if the new selection is a valid selection.
if %$newSelectionId% gtr %$availablePhpCount% goto invalidSelectionGiven

rem Check if the new selection is the same as the current selection.
if %$newSelectionId% equ %$currentPhpVersionId% goto currentSelectionGiven


rem --------------------------
rem  Implode Environment Path
rem --------------------------

rem Rebuild the path string while excluding any and all found PHP paths.
set "$pathString="

rem Iterate through the path array.
for /L %%a in (1,1,%$pathArrayCount%) do (

    rem Remove any trailing slash.
    if !$pathArray[%%a]:~-1! equ \ (
        set $path=!$pathArray[%%a]:~0,-1!
    ) else (
        set $path=!$pathArray[%%a]!
    )

    rem Get the last segment of the path.
    for %%b in (!$path!) do (
        set $lastSegment=%%~nxb
    )

    rem Check the last segment for a matching regex expression. IE: Any PHP folder.
    echo !$lastSegment! | findstr /R /C:"^php[1-9][0-9]*\.[0-9][0-9]*\.*[0-9]*[0-9]*" >nul

    rem If a match is not found, append the path to the path string and include a trailing semicolon.
    if !errorlevel! neq 0 (
        set $pathString=!$pathString!!$pathArray[%%a]!;
    )
)


rem ---------------------
rem  Add Chosen PHP Path
rem ---------------------

rem Add the selected PHP folder path to the end of the path string.
rem Note: Final path in environmental path not to include a trailing semicolon.
rem       Adding selected PHP folder path to front of environmental path would
rem       speed-up discoverability but unnecessarily complicate implosion.
set $pathString=%$pathString%%$pathToPhpFolders%\!$availablePhpArray[%$newSelectionId%]!


rem ----------------------------
rem  Set The Environmental Path
rem ----------------------------

rem Check if the CLI 'session' mode is being used.
if %$cliSessionMode% equ 1 (

    rem Show the success message.
    rem Note: Message must come first else we will loose
    rem       reference to newly selected PHP array value.
    call :sessionUpdateSuccessful

    rem Set the 'session' environmental path variable.
    endlocal && set "Path=%$pathString%" >nul

    exit /B 0
) else (

    rem Set the user environmental path variable.
    setx Path "%$pathString%" >nul

    rem Show the successful message.
    goto updateSuccessful
)


rem ====================================================================================================================
rem                                               Success Messages
rem ====================================================================================================================

rem -------------------
rem  Update successful
rem -------------------
:updateSuccessful

if %$cliMode% equ 0 (
    color %$colorSuccess%
    echo   Update Successful - The PHP CLI version is now !$availablePhpArray[%$newSelectionId%]!
    echo:
    echo   Press any key to exit.
    pause >nul
    exit 0
) else (
    echo:
    echo   Success - The PHP CLI version is now !$availablePhpArray[%$newSelectionId%]!
    exit /B 0
)


rem ---------------------------
rem  Session update successful
rem ---------------------------
:sessionUpdateSuccessful

echo:
echo   Success: This sessions PHP CLI version is now !$availablePhpArray[%$newSelectionId%]!

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
    echo:
    echo   Notice: Current selection was given - The PHP CLI version remains unchanged.
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
    echo:
    echo   Failure: An invalid php version was given - The PHP CLI version remains unchanged.
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
    echo:
    echo   Error: The $customInstallPath path "%$customInstallPath%" does not exist.
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
    echo:
    echo   Error: Neither of the default installation paths exists.
    echo:
    echo           1. %$defaultInstallPath[0]%
    echo           2. %$defaultInstallPath[1]%
    echo:
    echo          WampServer does not appear to be installed.
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
    echo:
    echo   Error: The $pathToPhpFolders path "%$pathToPhpFolders%" does not exist.
    echo:
    echo          See the WampServer website for help.
    exit /B 1
)