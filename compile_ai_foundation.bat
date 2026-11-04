@echo off
setlocal
cd /d "%~dp0"

ghdl -a --std=08 src\tr8_ai\tr8a32_isa_pkg.vhd
if errorlevel 1 exit /b 1
ghdl -a --std=08 src\tr8_ai\tr8a32_alu.vhd src\tr8_ai\tr8a32_register_file.vhd
if errorlevel 1 exit /b 1
ghdl -a --std=08 src\tr8_ai\tr8a32_timer.vhd
if errorlevel 1 exit /b 1
ghdl -a --std=08 src\tr8_ai\tr8a32_csr.vhd
if errorlevel 1 exit /b 1
ghdl -a --std=08 src\tr8_ai\tr8a32_cpu.vhd
if errorlevel 1 exit /b 1
ghdl -a --std=08 tb\tr8_ai\foundation\tr8a32_alu_tb.vhd ^
  tb\tr8_ai\foundation\tr8a32_register_file_tb.vhd
if errorlevel 1 exit /b 1
ghdl -a --std=08 tb\tr8_ai\cpu\tr8a32_cpu_tb.vhd
if errorlevel 1 exit /b 1
ghdl -a --std=08 tb\tr8_ai\cpu\tr8a32_interrupt_tb.vhd tb\tr8_ai\cpu\tr8a32_exception_tb.vhd tb\tr8_ai\cpu\tr8a32_misaligned_tb.vhd
if errorlevel 1 exit /b 1
ghdl -a --std=08 src\tr8_ai\npu_int8_mac.vhd src\tr8_ai\npu_array_2x2.vhd
if errorlevel 1 exit /b 1
ghdl -a --std=08 src\tr8_ai\npu_controller.vhd
if errorlevel 1 exit /b 1
ghdl -a --std=08 src\tr8_ai\tr8a32_memory.vhd src\tr8_ai\tr8a32_soc.vhd
if errorlevel 1 exit /b 1
ghdl -a --std=08 tb\tr8_ai\memory\tr8a32_memory_tb.vhd ^
  tb\tr8_ai\soc\tr8a32_soc_tb.vhd
if errorlevel 1 exit /b 1
ghdl -a --std=08 tb\tr8_ai\peripherals\tr8a32_timer_tb.vhd
if errorlevel 1 exit /b 1
ghdl -a --std=08 tb\tr8_ai\peripherals\tr8a32_csr_tb.vhd
if errorlevel 1 exit /b 1
ghdl -a --std=08 tb\tr8_ai\npu\npu_int8_mac_tb.vhd ^
  tb\tr8_ai\npu\npu_array_2x2_tb.vhd
if errorlevel 1 exit /b 1
ghdl -a --std=08 tb\tr8_ai\npu\npu_controller_tb.vhd
if errorlevel 1 exit /b 1
ghdl -a --std=08 tb\tr8_ai\soc\tr8a32_npu_integration_tb.vhd
if errorlevel 1 exit /b 1
echo TR-8-A32 foundation compilation successful.
exit /b 0
