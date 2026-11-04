# Verification Report

The project is compiled with GHDL using VHDL-2008. Unit testbenches cover the
AND gate, ALU, register file, program counter, instruction ROM, data RAM, and
control unit. The CPU integration test uses a generic ROM program that checks:

- STORE followed by LOAD read-back from RAM address `0x10`
- subtraction, zero result, unsigned underflow, and 8-bit addition overflow
- AND, OR, XOR, and NOT
- JZ taken and not taken, plus JMP
- NOP, HALT stability, and synchronous reset/restart

Run `test_all.bat` to compile and execute every testbench. Generated waveform
files are ignored because they are reproducible build artifacts.
