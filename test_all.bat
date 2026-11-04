@echo off
setlocal
cd /d "%~dp0"
call compile.bat
if errorlevel 1 exit /b 1

if not exist sim mkdir sim
set FAILED=0
for %%T in (TB_AND_GATE TB_ALU TB_REGISTER_FILE TB_PROGRAM_COUNTER TB_INSTRUCTION_ROM TB_DATA_RAM TB_CONTROL_UNIT TB_TR8_CPU) do (
  echo === %%T ===
  ghdl -e --std=08 %%T
  if errorlevel 1 set FAILED=1
  ghdl -r --std=08 %%T --wave=sim\%%T.ghw
  if errorlevel 1 set FAILED=1
)

if "%FAILED%"=="1" (
  echo One or more tests failed.
  exit /b 1
)
echo All TR-8 tests passed.
exit /b 0
