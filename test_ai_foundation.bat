@echo off
setlocal
cd /d "%~dp0"
call compile_ai_foundation.bat
if errorlevel 1 exit /b 1

if not exist sim mkdir sim
ghdl -e --std=08 TR8A32_ALU_TB
if errorlevel 1 exit /b 1
ghdl -r --std=08 TR8A32_ALU_TB --wave=sim\tr8a32_alu.ghw
if errorlevel 1 exit /b 1

ghdl -e --std=08 TR8A32_REGISTER_FILE_TB
if errorlevel 1 exit /b 1
ghdl -r --std=08 TR8A32_REGISTER_FILE_TB --wave=sim\tr8a32_register_file.ghw
if errorlevel 1 exit /b 1

ghdl -e --std=08 TR8A32_CPU_TB
if errorlevel 1 exit /b 1
ghdl -r --std=08 TR8A32_CPU_TB --wave=sim\tr8a32_cpu.ghw
if errorlevel 1 exit /b 1
ghdl -e --std=08 TR8A32_INTERRUPT_TB
if errorlevel 1 exit /b 1
ghdl -r --std=08 TR8A32_INTERRUPT_TB --wave=sim\tr8a32_interrupt.ghw
if errorlevel 1 exit /b 1
ghdl -e --std=08 TR8A32_MEMORY_TB
if errorlevel 1 exit /b 1
ghdl -r --std=08 TR8A32_MEMORY_TB --wave=sim\tr8a32_memory.ghw
if errorlevel 1 exit /b 1

ghdl -e --std=08 TR8A32_SOC_TB
if errorlevel 1 exit /b 1
ghdl -r --std=08 TR8A32_SOC_TB --wave=sim\tr8a32_soc.ghw
if errorlevel 1 exit /b 1
ghdl -e --std=08 TR8A32_TIMER_TB
if errorlevel 1 exit /b 1
ghdl -r --std=08 TR8A32_TIMER_TB --wave=sim\tr8a32_timer.ghw
if errorlevel 1 exit /b 1
ghdl -e --std=08 TR8A32_CSR_TB
if errorlevel 1 exit /b 1
ghdl -r --std=08 TR8A32_CSR_TB --wave=sim\tr8a32_csr.ghw
if errorlevel 1 exit /b 1
ghdl -e --std=08 NPU_INT8_MAC_TB
if errorlevel 1 exit /b 1
ghdl -r --std=08 NPU_INT8_MAC_TB --wave=sim\npu_int8_mac.ghw
if errorlevel 1 exit /b 1
ghdl -e --std=08 NPU_ARRAY_2X2_TB
if errorlevel 1 exit /b 1
ghdl -r --std=08 NPU_ARRAY_2X2_TB --wave=sim\npu_array_2x2.ghw
if errorlevel 1 exit /b 1
ghdl -e --std=08 NPU_CONTROLLER_TB
if errorlevel 1 exit /b 1
ghdl -r --std=08 NPU_CONTROLLER_TB --wave=sim\npu_controller.ghw
if errorlevel 1 exit /b 1
ghdl -e --std=08 TR8A32_NPU_INTEGRATION_TB
if errorlevel 1 exit /b 1
ghdl -r --std=08 TR8A32_NPU_INTEGRATION_TB --wave=sim\tr8a32_npu_integration.ghw
if errorlevel 1 exit /b 1

echo TR-8-A32 foundation tests passed.
exit /b 0
