@echo off

REM Make sure set only works for this batch file.
SetLocal

REM name of the Python script
REM %~dp0 is the path of working batch file. Assume the batch file and Python sccipt are put in the same directory.
set OUTPUT_PATH=%~dp0
set SH_SCRIPT=%OUTPUT_PATH%BashEnv.sh
set SH_TEMPLATE=%OUTPUT_PATH%BashEnv_template.sh
set RESIZE_EXE=C:\Portable\02_SW_Settings\AutoHotKey\XshellToggleWindowSize.exe


REM During this conversion, only the '#' in the first character of a line will be treated as comment and won't be passed to the actual command file.
findstr /V "^#" %SH_TEMPLATE% > %SH_SCRIPT%

REM refer to mfg script (build.bat) to set current data/time
for /f "tokens=1,2,3 delims=/ " %%a in ('date /t') do (set curDate=%%a-%%b-%%c)
for /f "tokens=2,3,4 delims=.: " %%a in ('ver^|time') do (set curTime=%%a:%%b:%%c)

REM Don't forget the leading space of Python command
echo date -s "%curDate% %curTime%" >> %SH_SCRIPT%

REM Run this AutoHotKey script to restore Xshell windows size then maximize it, so that xterm can work fine.
call %RESIZE_EXE%

REM Uncommnet 'pause' and change the first line to 'echo on' to debug
REM pause