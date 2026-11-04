# Development Log

The original AND gate, ALU, and register-file implementations were inspected
and retained. The program counter, instruction ROM, data RAM, control unit,
and CPU were then added with dedicated assertion-based testbenches. The ISA is
now centralized in `tr8_isa_pkg.vhd`, the ROM is program-configurable through a
generic for integration tests, and a Python assembler uses the same field
layout. The final validation runs all existing and new testbenches under GHDL
VHDL-2008.

The next-generation milestone has started separately under `src/tr8_ai` and
`tb/tr8_ai`. The first foundation contains a 32-bit ALU, a 32-register file
with hardwired `x0`, and focused tests. A minimal multi-cycle CPU core now
supports register ALU operations, ADDI, LW, SW, BEQ, BNE, LUI, and HALT through
explicit instruction and data interfaces. A first memory subsystem and SoC
wrapper now connect those interfaces with synchronous data writes, instruction
fetch, and unmapped-address error reporting. The SoC now accepts a configurable
program image and decodes a timer/debug peripheral at `0x00000400`. The timer
has a pending IRQ output, but CPU trap and interrupt delivery are intentionally
deferred. A minimal CSR/trap block now captures `MEPC` and `MCAUSE`, vectors
to `MTVEC = 0x00000100`, and supports `ERET`; the timer IRQ is wired into the
SoC CPU. The legacy TR-8 hierarchy remains unchanged.
