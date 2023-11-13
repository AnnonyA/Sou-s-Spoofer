@echo off

set scriptpath=%~dp0

  findstr /C:"RUN_NPM_UPDATE" "%scriptpath%\STATUS.txt" >nul
  if not errorlevel 1 (
    echo SStlr - Updating required NPM packages
    call npm install
)

call npm install hwid@0.3.0

node autoupd2.js

PAUSE
