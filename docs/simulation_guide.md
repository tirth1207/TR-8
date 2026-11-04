# Simulation Guide

Use `test_all.bat` for all assertion-based tests or `simulate_cpu.bat` for the
CPU waveform. GHDL uses VHDL-2008 and writes GHW files into `sim`. In GTKWave,
expand the CPU testbench hierarchy and add the debug ports plus the internal
clock and reset. The CPU testbench stops only after reset, arithmetic, STORE,
HALT, and restart checks pass.
