# WampServer PHP CLI Version Changer

[![GitHub version](https://img.shields.io/github/tag/custom-dev-tools/WampServer-PHP-CLI-Version-Changer.svg?label=WampServer-PHP-CLI-Version-Changer&logo=github)](https://github.com/custom-dev-tools/WampServer-PHP-CLI-Version-Changer/releases) ![Maintained](https://img.shields.io/static/v1.svg?label=maintened&message=yes&color=informational&logo=github) [![Stars](https://img.shields.io/github/stars/custom-dev-tools/WampServer-PHP-CLI-Version-Changer.svg?color=brightgreen&logo=github)](https://github.com/custom-dev-tools/WampServer-PHP-CLI-Version-Changer/stargazers)
 
[![GitHub License](https://img.shields.io/github/license/custom-dev-tools/WampServer-PHP-CLI-Version-Changer.svg?color=informational&logo=github)](https://github.com/custom-dev-tools/WampServer-PHP-CLI-Version-Changer/blob/master/LICENSE) [![GitHub last commit](https://img.shields.io/github/last-commit/custom-dev-tools/WampServer-PHP-CLI-Version-Changer.svg?logo=github)](https://github.com/custom-dev-tools/WampServer-PHP-CLI-Version-Change/commits/master) [![GitHub open issues](https://img.shields.io/github/issues-raw/custom-dev-tools/WampServer-PHP-CLI-Version-Changer.svg?color=brightgreen&logo=github)](https://github.com/custom-dev-tools/WampServer-PHP-CLI-Version-Changer/issues?q=is%3Aopen+is%3Aissue) [![GitHub closed issues](https://img.shields.io/github/issues-closed-raw/custom-dev-tools/WampServer-PHP-CLI-Version-Changer.svg?color=brightgreen&logo=github)](https://github.com/custom-dev-tools/WampServer-PHP-CLI-Version-Changer/issues?q=is%3Aissue+is%3Aclosed)

WampServer PHP CLI Version Changer is a Microsoft Windows batch script that allows you to easily change between installed WampServer PHP CLI versions using the users environment 'path' variable.

## Table Of Contents

* [Minimum Requirements](#minimum-requirements)
* [Installation](#installation)
* [Configuration](#configuration)
* [How To Use](#how-to-use)
  * [Text Based User Interface (TUI)](#text-based-user-interface-tui)
  * [Command Line Interface (CLI)](#command-line-interface-cli)
    * [Session Mode](#session-mode)
* [FAQ's](#faqs)

## Minimum Requirements

The following are required for the CLI Changer script to function correctly.
- Microsoft Windows 7 and up.
- WampServer v3.0.0 and up.

## Installation

No installation is required.

At just over 13KB the CLI Changer script is small enough to be saved anywhere in your file system.

**Tip:** Once you have save the CLI Changer script, create a desktop shortcut to it for quick and easy access.

## Configuration

No configuration is necessary if your installed WampServer in its default directory.

The default installation directories are:
- `C:\wamp` - For 32-bit installations.
- `C:\wamp64` - For 64-bit installations.

If you installed WampServer in a custom directory, then follow the steps below:

1. Open the CLI Changer script in your preferred text editor.
2. Append your custom install path to the `$customInstallPath` variable.
3. Save the file and close your text editor.

Example: A customised WampServer install path.
```
rem +------------------------------------------------+
rem |            User Defined Variable(s)            |
rem +------------------------------------------------+

rem WampServer custom install path.
rem Note: Trailing slash is not required.
set $customInstallPath=D:\WampServer 64-Bit
```

 **IMPORTANT:** Do not add quotation marks around your custom installation path, even if the path contains spaces.

## How To Use

There are two ways you can use the CLI Changer script.

* Text based user interface (TUI).
* Command line interface (CLI).
  * Session mode

### Text Based User Interface (TUI)

Upon running the CLI Changer script you will be presented with a numbered list of installed PHP versions that you can select from.

The exact list of installed PHP CLI versions is dependent on what you currently have in your WampServer PHP addon folder.

```
Available PHP CLI Versions
--------------------------

1 - php5.5.38
2 - php5.6.31
3 - php5.6.34
4 - php7.0.23 - Current
5 - php7.0.28
6 - php7.1.15
7 - php7.1.19
8 - php7.2.3

Selection (1-8): 8

Update Successful - The PHP CLI version is now php7.2.3

Press any key to exit.
```

If a PHP version has previously been set, it will display in the list as "Current".

To select a PHP version:
1. Key in the digit(s) to the left of the desired PHP version.
2. Press the ENTER key.

The CLI Changer script will display the newly set PHP version number and prompt you to press any key to exit.

**Note:** The newly selected PHP version will only be available to new command line windows. Existing windows will still reference the previously set PHP version.

To exit the CLI Changer script without making any changes just press the ENTER key.

Should you make an invalid selection or should the selection be the same as the currently selected version then you will receive feedback indicating so.

### Command Line Interface (CLI)

To update the PHP CLI version number directly from the command line, you can pass in the desired PHP version via the scripts first argument. This will bypass the selection screen and go straight to setting the desired version number.

From a CMD prompt:
```
C:\>: "C:\path\to\cli_changer.bat" php7.2.3
```

From a Bash or Powershell prompt:
```
$ start "C:\path\to\cli_changer.bat" php7.2.3
```

**Note 1:** You will need to enclose the CLI Changer script path in quotes if the path contains any spaces.

**Note 2:** You will need to know the available PHP CLI version(s) in advance prior to using this command.

Following execution, an exit code will be given:

- `0` - Success
- `1` - Failure

**Tip:** Calling scripts via the command line is common during (automated) development, testing and deployment. EG: Incorporate it into your build files...

#### Session Mode

Should you have the need to only change the PHP version number within an open command window (session) and not across your whole system then you can use the `--temp` option.

From a CMD prompt:
```
C:\>: "C:\path\to\cli_changer.bat" php7.2.3 --temp
```

From a Bash or Powershell prompt:
```
$ start "C:\path\to\cli_changer.bat" php7.2.3 --temp
```

The short command line option `-t` is also available.

**Note:** Enclosing the script path in quotes if it contains spaces and knowing the available PHP CLI version(s) in advance is still required.

Following execution, an exit code will be given:

- `0` - Success
- `1` - Failure

**Note:** Using the `--temp` or `-t` option will only change the PHP version number within that command window. Multiple command windows can be open and the PHP version number changed without affecting other open command windows. 

## FAQ's

### What are environment path variables and how do they work? 

Environment 'path' variables allow the user (and system) to call an executable without the need to use the executables absolute (full) path. Windows parses the path variables from left to right, with the 'user' path being appended to the 'system' path. (IE: path = system.path + user.path)

When the user (or the user's script) calls `php` or `php.exe`, the path pointing to the executable will be used. If an environment path contains two or more paths to a PHP executable, then only the first one found is executed. The other php executables will never be called, ever.

Based on this information and pursuant to the successful selection of a PHP version number, this script scans and then removes any and all reference to any php executable path(s) found within the environment 'user' path (or the cmd window 'session' path) prior to appending the selected PHP version path.

The PHP CLI version number returned by typing `php -v` at the command prompt should be the same as that selected by you when using this script. If it is not, there is a strong chance that there is reference to a PHP executable within the environment 'system' path. To correct this situation, you must remove this reference from the environment 'system' path manually.

Access the environment 'user' and 'system' paths by: 

* Windows 7: Clicking 'Start' -> 'Control Panel' -> 'System' -> 'Advanced system settings' -> 'Environment Variables...'
* Windows 10: Clicking 'Start Search' -> Type 'env' -> Click the result 'Edit system environment variables' -> 'Environment Variables...'

### How do I remove the error at the bottom of the WampServer right-click menu?

When using WampServer v3.1.2 - v3.1.7 inclusive, the below error message may be displayed.

```
Error C:/wamp or PHP in PATH
```

Clicking on this error will open a command window displaying the below message.

```
Sorry,

There is an error.

There is Wampserver path (C:/wamp)
into Windows PATH environment variable: (C:\wamp\bin\php\phpX.X.X)

It seems that a PHP installation is declared in the environment variable PATH
C:\wamp\bin\php\phpX.X.X

Wampserver does not use, modify or require the PATH environmental variable.
Using a PATH on Wampserver or PHP version
is detrimental to the proper functioning of Wampserver.

Press ENTER to continue...
```

This error can be suppressed by right-clicking the WampServer icon in the taskbar notification area and selecting: _Wamp Settings -> Do not verify PATH_

#### Why would you want to suppress this error?

Because currently, WampServer does not have the ability to change the CLI version of PHP should your script(s) require a specific version.

#### But isn't that what right-clicking the WampServer icon in the taskbar notification area and selecting: _Tools -> Change PHP CLI version_ does?

No, it doesn't. This selection currently changes the CLI version that the _WampServer's scripts use_, not what your scripts use when called from the command line.

#### So can I safely use this script?

Currently, yes (but this may change if WampServer decides in the future to begin using either or both of your systems environment path variables).

### How do I add more PHP versions?
To add more PHP versions to your WampServer v3 installation visit [SourceForge](https://sourceforge.net/projects/wampserver/files/WampServer%203/WampServer%203.0.0/Addons/Php/).