echo off
title NCMD
echo Noobist Command Prompt.
echo (C) Copyright to Microsoft Corp.
echo Special Commands can be seen in 'ncmdhelp' command.
color 0a
echo.

:cmd
set /p "cmd=[%cd%] "

if /i "%cmd%" == "ncmdhelp" goto :ncmdhelp
if /i "%cmd%" == "asciistarwars" goto :telnetsw
if /i "%cmd%" == "cmd" goto :cmdforbidden
if /i "%cmd%" == "unblock" goto :unblockhelp
if /i "%cmd%" == "unblock taskmgr" goto :unblocktaskmgr
if /i "%cmd%" == "unblock regedit" goto :unblockregedit
if /i "%cmd%" == "unblock cmd" goto :unblockcmd
if /i "%cmd%" == "block" goto :blockhelp
if /i "%cmd%" == "block taskmgr" goto :blocktaskmgr
if /i "%cmd%" == "block regedit" goto :blockregedit
if /i "%cmd%" == "block cmd" goto :blockcmd
%cmd%

:def
echo.
title NCMD [Last Command Executed: %time%]
goto :cmd

:cmdforbidden
echo You don't need it when you use this.
goto :def

:telnetsw
if not exist C:\Windows\system32\telnet.exe goto :telnetswerror
set /p "telnetyesno=You are about to open telnet. Make sure you have an internet connection. Continue? (Y/N)"
if /i "%telnetyesno%" == "Y" goto :telnetswdone
goto :def

:telnetswdone
color 07
telnet towel.blinkenlights.nl
color 0a
goto :def

:telnetswerror
echo Telnet service is disabled. Please enable the telnet service to watch.
goto :def

:ncmdhelp
echo Noobist Command Prompt
echo (C) Copyright Microsoft Corp.
echo.
echo Primary Commands:
echo ncmdhelp = Special commands help.
echo.
echo Block Commands:
echo Blocks a program.
echo block = Shows block help.
echo block taskmgr = Blocks Task Manager
echo block regedit = Blocks Registry Editor
echo block cmd = Blocks Command Prompt
echo.
echo Unblock Commands:
echo These commands is used when your program has been blocked.
echo unblock = Shows unblock help.
echo unblock taskmgr = Unblocks Task Manager.
echo unblock regedit = Unblocks Registry Editor.
echo unblock cmd = Unblocks Command Prompt.
echo.
echo Miscellaneous Commands:
echo Just for fun commands only.
echo asciistarwars = Shows Star Wars Episode IV in ASCII. (Needs telnet service and internet connection).
goto :def

:unblockhelp
echo Unblock
echo Usage: unblock [program]
echo Function: Unblock programs that has been blocked.
echo.
echo Programs:
echo.
echo taskmgr
echo regedit
echo cmd
echo.
echo Example: unblock taskmgr = Unblocks Task Manager.
goto :def

:unblocktaskmgr
echo Unblocking Task Manager...
REG add HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System /v DisableTaskMgr /t REG_DWORD /d 0 /f
echo Now you can try opening Task Manager again.
goto :def

:unblockregedit
echo Unblocking Registry Editor...
REG add HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System /v DisableRegistryTools /t REG_DWORD /d 0 /f
if errorlevel 1 goto :unblockregeditalt
echo Now you can try opening Registry Editor again.
goto :def

:unblockregeditalt
echo.
echo An error occured, Trying the second way..
echo 1. Click on the Start - Run and type gpedit.msc on the field.
echo 2. Navigate to:
echo - User Configuration
echo - Administrative Templates
echo - System.
echo 3. On the setting: Prevent access to registry editing tools.
echo 4. Click Disabled and click on the OK button to save settings.
echo 5. You can try opening Registry Editor again.
goto :def

:unblockcmd
echo Unblocking Command Prompt...
REG add HKCU\Software\Policies\Microsoft\Windows\System /v DisableCMD /t REG_DWORD /d 0 /f
if errorlevel 1 goto :unblockerror
echo Now you can try opening Command Prompt again.
goto :def

:blockhelp
:unblockhelp
echo block
echo Usage: block [program]
echo Function: Block programs.
echo.
echo Programs:
echo.
echo taskmgr
echo regedit
echo cmd
echo.
echo Example: block taskmgr = Blocks Task Manager.
goto :def

:blocktaskmgr
echo Blocking Task Manager...
REG add HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System /v DisableTaskMgr /t REG_DWORD /d 1 /f
if errorlevel 1 goto :unblockerror
echo You can try opening Task Manager again.
goto :def

:blockregedit
echo Blocking Registry Editor...
REG add HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System /v DisableRegistryTools /t REG_DWORD /d 1 /f
echo You can unblock Registry Editor with unblock command.
goto :def

:blockcmd
echo Blocking Command Prompt...
REG add HKCU\Software\Policies\Microsoft\Windows\System /v DisableCMD /t REG_DWORD /d 1 /f
echo You can unblock Command Prompt with unblock command.
goto :def

:unblockerror
echo An error occured, try unblocking Registry Editor.
goto :def
