@echo off
REM Store the absolute path to the Dev directory
SET DevDir=%~dp0
SET DevDir=%DevDir:~0,-1%
echo "DevDir=%DevDir%"

REM Store the absolute path to the repo directory
for %%I in ("%DevDir%\..\") do set "RepoDir=%%~fI"
SET RepoDir=%RepoDir:~0,-1%
echo "RepoDir=%RepoDir%"

REM Check if core.hooksPath is set, otherwise set to the dev/hooks directory
CALL :get_hooksPath hooksPath
echo "BEFORE hooksPath=%hooksPath%"

git config core.hooksPath || git config core.hooksPath "%DevDir%\hooks"

CALL :get_hooksPath hooksPath
echo "AFTER  hooksPath=%hooksPath%"

EXIT /B 0

:get_hooksPath
FOR /F "tokens=* USEBACKQ" %%F IN (`git config core.hooksPath`) DO (
SET %~1=%%F
)
EXIT /B 0
