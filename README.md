# WampServer PHP CLI Version Changer
WampServer PHP CLI version changer is a Microsoft Windows batch script that allows you to easily add and then change between available WampServer PHP CLI versions using the users environmental path.

## Minimum Requirements
The following are required for the CLI Changer script to function correctly.
- Microsoft Windows 7 and up.
- WampServer v3.0.0 and up.

## Installation
No installation is required.

At just over 7kB the CLI Changer script is small enough to be saved anywhere in your file system.

**Note:** To operate seamlessly the Microsoft Windows "cmd.exe" executable must be in your system path. The standard installation path is ``C:\Windows\System32``. 

**Tip:** Once you have save the CLI Changer script, create a desktop shortcut to it for quick and easy access.

## Configuration
If using a WampServer 32-bit version with default settings, then no configuration is necessary.

If using a WampServer 64-bit version **OR** a different install path was set during installation, then follow the steps below:

1. Open the CLI Changer script in your preferred text editor.
2. Change the value of the `$pathToInstall` variable to match that of your WampServer install path, taking care **not to** use quotes around the value.
3. Once you have changed the value, save and close your editor.

For reference, the default WampServer install paths are:
- `C:\wamp` - For 32-bit installations.
- `C:\wamp64` - For 64-bit installations.

Example: A customised WampServer install path.
```
rem +------------------------------------------------+
rem |            User Defined Variable(s)            |
rem +------------------------------------------------+

rem WampServer install path.
set $pathToInstall=D:\WampServer64
```

## How To Use
There are two ways you can use the CLI Changer script.

* Text based user interface (TUI).
* Command line interface (CLI).

### Text Based User Interface (TUI)
Upon running the CLI Changer script you will be presented with a numbered list of available PHP versions that you can select from.

The exact list of available PHP CLI versions is dependent on what you currently have in your WampServer PHP addon folder.

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

**Note:** The newly selected PHP version will only be available to new command line windows opened after the change. Existing windows will still reference any previously set PHP version.

To exit the CLI Changer script without making any changes just press the ENTER key.

Should you make an invalid selection or should the selection be the same as the currently selected version then you will receive feedback indicating so.

### Command Line Interface (CLI)
To update the PHP CLI version number directly from the command line, you can pass in the desired PHP version via the scripts first argument. This will bypass the selection screen and go straight to setting the desired version number.

```
cmd_prompt>: start "path\to\cli_changer.bat" php7.2.3
```

**Note 1:** You will need to enclose the scripts path in double quotation marks if the path contains any spaces.

**Note 2:** You will need to know the available PHP CLI version(s) in advance prior to using this command.

Following execution, an exit code will be given:

- `0` - Success
- `1` - Failure

**Tip:** Calling scripts via the command line is common during (automated) development, testing and deployment. EG: Incorporate it into your build files...

## FAQ's
### How do I remove the error at the bottom of the WampServer right-click menu?
As of WampServer v3.1.2 the below error message may be displayed.

```
ERROR C:/wamp or PHP in PATH"
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

Press ENTER top continue...
```

This error can be suppressed by right-clicking the WampServer icon in the taskbar notification area and selecting: _Wamp Settings -> Do not verify PATH_

**Question 1:** Why would you want to suppress this error? Because currently, WampServer does not have the ability to change the CLI version of PHP should your script(s) require a specific version.

**Question 2:** But isn't that what right-clicking the WampServer icon in the taskbar notification area and selecting: _Tools -> Change PHP CLI version_ does? No, it doesn't. This selection currently changes the CLI version that the _WampServer's scripts use_, not what your scripts use when called from the command line.

**Question 3:** So can I safely use this script? Currently, yes (but this may change if WampServer decides in the future to begin using either or both of your systems environmental path variables).

### How do I add more PHP versions?
To add more PHP versions to your WampServer v3 installation visit [SourceForge](https://sourceforge.net/projects/wampserver/files/WampServer%203/WampServer%203.0.0/Addons/Php/).