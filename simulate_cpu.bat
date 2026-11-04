@echo off
setlocal
cd /d "%~dp0"
call compile.bat
if errorlevel 1 exit /b 1
if not exist sim mkdir sim
ghdl -e --std=08 TB_TR8_CPU
if errorlevel 1 exit /b 1
ghdl -r --std=08 TB_TR8_CPU --wave=sim\tr8_cpu.ghw
if errorlevel 1 exit /b 1

if defined GTKWAVE_PATH (
  if exist "%GTKWAVE_PATH%" start "" "%GTKWAVE_PATH%" sim\tr8_cpu.ghw
) else (
  where gtkwave >nul 2>nul
  if not errorlevel 1 start "" gtkwave sim\tr8_cpu.ghw
)
exit /b 0
