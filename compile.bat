@echo off
setlocal
cd /d "%~dp0"

ghdl -a --std=08 src\and_gate.vhd src\alu.vhd src\register_file.vhd ^
  src\program_counter.vhd src\instruction_rom.vhd src\data_ram.vhd ^
  src\control_unit.vhd src\tr8_cpu.vhd
if errorlevel 1 exit /b 1

ghdl -a --std=08 tb\tb_and_gate.vhd tb\tb_alu.vhd tb\tb_register_file.vhd ^
  tb\tb_program_counter.vhd tb\tb_instruction_rom.vhd tb\tb_data_ram.vhd ^
  tb\tb_control_unit.vhd tb\tb_tr8_cpu.vhd
if errorlevel 1 exit /b 1
echo Compilation successful.
exit /b 0
