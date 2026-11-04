# Simulation Guide

Use `test_all.bat` for all assertion-based tests or `simulate_cpu.bat` for the
CPU waveform. GHDL uses VHDL-2008 and writes GHW files into `sim`. In GTKWave,
expand the CPU testbench hierarchy and add the debug ports plus the internal
clock and reset. The CPU testbench stops only after reset, arithmetic, STORE,
LOAD read-back, branching, HALT, and restart checks pass. The useful signals
are `PC_OUT`, `CURRENT_INSTRUCTION`, `DEBUG_OPCODE`, `DEBUG_RD`,
`DEBUG_RS`, `DEBUG_IMMEDIATE`, `DEBUG_ALU_A`, `DEBUG_ALU_B`,
`DEBUG_ALU_SEL`, `DEBUG_ALU_RESULT`, `DEBUG_REG_WE`, `DEBUG_REG_WADDR`,
`DEBUG_REG_WDATA`, `DEBUG_RAM_WE`, `DEBUG_RAM_ADDR`, `DEBUG_RAM_DATA`,
`DEBUG_ZERO`, and `HALTED`.
