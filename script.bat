@ECHO OFF
SET "search_dir=%~dp1"
SET "file_extension=%~x2"

SET "current_dir=%~dp0"
SET log_file_name=file_search_log.txt
SET "log_file_path=%current_dir%%log_file_name%"

IF "%search_dir%"=="" SET search_dir="%homedrive%%homepath%"
echo %file_extension%
IF "%file_extension%"=="" (IF "%2"=="" (SET file_extension=.bat) ELSE SET "file_extension=.%2")

ECHO Current date time is %date% %time%
ECHO Set search dir as %search_dir%
ECHO Set file extension as %file_extension%
ECHO Log file path %log_file_path%

ECHO %date% > "%log_file_path%"
ECHO %time% >> "%log_file_path%"
ECHO. >> "%log_file_path%"

REM Putting file names and paths in a "list" 
SETLOCAL enableDelayedExpansion
SET "file_path_name_list="
for /R "%search_dir%" %%f in ("*%file_extension%") do (
  IF "!file_path_name_list!"=="" (
      SET "file_path_name_list="%%~nxf" "%%f""
  ) ELSE (
      SET "file_path_name_list=!file_path_name_list! "%%~nxf" "%%f""
  )
)

REM Looping through saved "list"
for %%a in (%file_path_name_list%) do (
  ECHO %%a >> "%log_file_path%"
)

START notepad.exe "%log_file_path%"
PAUSE
taskkill /FI "WINDOWTITLE eq %log_file_name:~0,-4%*" /T /F
DEL /Q "%log_file_path%"
EXIT /B 0
