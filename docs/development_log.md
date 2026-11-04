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
SoC CPU. The first NPU datapath now includes a signed INT8 MAC and fixed 2x2
matrix engine with bias addition and busy/done/error status. The legacy TR-8
hierarchy remains unchanged.
The NPU foundation now has a memory-mapped controller with local 2x2 input,
weight, bias, and output registers. It exposes start, busy, done, and error
status and is verified independently. The controller is now routed through
the SoC decoder, and a CPU-driven integration test verifies register
programming, start/poll behavior, and result readback.
Activation controls now support ReLU and widened signed 32-bit saturation.
Direct array tests cover negative-result clamping and positive overflow
clamping while the existing CPU-NPU path remains compatible.
NPU completion now generates a one-cycle interrupt pulse, combined with the
timer IRQ at the CPU. The CPU prevents immediate retriggering while executing
an interrupt handler, and the integration test clears NPU DONE before ERET.
The controller programming model now includes an error-code register, a
completion IRQ enable bit, and a busy-cycle performance counter, with focused
verification coverage.
The NPU controller operand registers now back indexed local tensor storage
for inputs, weights, and biases. The legacy register addresses are preserved;
parameterized SRAM depth and generalized tensor dimensions remain future work.
The controller now exposes explicit M/K/N dimensions and rejects unsupported
configurations with error code `3`, rather than silently accepting dimensions
the fixed 2x2 datapath cannot execute.
