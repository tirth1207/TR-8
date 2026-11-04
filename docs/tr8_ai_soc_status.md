# TR-8-A32N SoC Status

The current SoC milestone contains:

- A single-master CPU instruction interface and 32-bit multi-cycle CPU.
- A configurable instruction ROM and 32-bit data memory.
- Synchronous data-memory writes and asynchronous read visibility for the current transaction.
- Ready and error responses for data transactions; ordinary data RAM is mapped at `0x00000000`-`0x000000FF`.
- A memory-mapped timer at `0x00000400`-`0x0000040F`.
- A minimal CSR block with fixed `MTVEC = 0x00000100`, `MEPC`, and `MCAUSE`.
- A memory-mapped fixed 2x2 INT8 NPU controller at `0x00000100`-`0x000001FF`.
- CPU-driven NPU programming, polling, and result-readback integration coverage.
- Timer and NPU completion IRQs combined at the CPU interrupt input.

The timer exposes a counter at offset `0x0`, compare value at `0x4`, control at `0x8`, and pending-interrupt clear at `0xC`. Software must clear a level-sensitive timer request before returning from its handler.

The CPU accepts the combined timer/NPU IRQ at an instruction-fetch boundary, saves the current PC in `MEPC`, records cause 1 in `MCAUSE`, and jumps to `MTVEC`. `ECALL` records cause 11; misaligned `LW`/`SW` raise causes 4/6; load/store bus errors raise causes 5/7. `ERET` returns to `MEPC`. The CPU currently suppresses further external IRQ entry while a trap handler is active. Interrupt masking, priority arbitration, nested traps, and independently vectored sources are not implemented.

The NPU supports a fixed 2x2 signed INT8 matrix operation with two signed 32-bit biases, optional arithmetic right shift, signed 32-bit saturation, and ReLU. Its controller provides indexed operand registers, output registers, status/error registers, an IRQ-enable bit, and a busy-cycle counter. Completion IRQ is a one-cycle pulse while DONE remains latched until software clears it. Generalized tensor dimensions, parameterized SRAM, DMA, and concurrent NPU memory traffic remain future work.

The memory model is currently a simulation/reference implementation. FPGA block-RAM inference, synthesis, timing closure, and resource measurements have not yet been verified.
