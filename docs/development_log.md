# Development Log

The original AND gate, ALU, and register-file implementations were inspected
and retained. The program counter, instruction ROM, data RAM, control unit,
and CPU were then added with dedicated assertion-based testbenches. The ISA is
now centralized in `tr8_isa_pkg.vhd`, the ROM is program-configurable through a
generic for integration tests, and a Python assembler uses the same field
layout. The final validation runs all existing and new testbenches under GHDL
VHDL-2008.
