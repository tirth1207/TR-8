# TR-8-A32N SoC Status

The current SoC milestone contains:

- A single-master CPU instruction interface.
- A configurable 32-bit word-addressed internal instruction memory.
- A 32-bit word-addressed data memory.
- Synchronous data-memory writes.
- Asynchronous read visibility for the current CPU transaction.
- A simple ready response.
- An unmapped-address error response.
- A top-level CPU-plus-memory wrapper.
- A memory-mapped timer/debug peripheral at `0x00000400`-`0x0000040F`.
- A minimal CSR block with fixed `MTVEC = 0x00000100`, `MEPC`, and `MCAUSE`.
- Timer IRQ wiring into the CPU trap-entry input.

The timer exposes a counter at offset `0x0`, compare value at `0x4`, control
at `0x8`, and pending-interrupt clear at `0xC`. It provides a pending `IRQ`
signal internally, but the CPU does not yet have trap/CSR logic to consume it.

The memory map is intentionally minimal. Addresses with bits 31..10 clear
select the initial 1 KiB data window; other data addresses return `ERROR`.
NPU windows, interrupt delivery, and bus arbitration are not implemented yet.

The CPU now accepts an IRQ at an instruction-fetch boundary, saves the current
PC in `MEPC`, records cause `1` in `MCAUSE`, jumps to `MTVEC`, and supports
`ERET` return. A full interrupt-enable/masking model and interrupt controller
remain future work.

The timer IRQ is wired to this CPU input in the SoC wrapper. Software must
clear the timer pending bit before returning from the handler; otherwise the
level-sensitive request can cause another trap.

The memory model is a reference implementation for simulation. FPGA block-RAM
inference and a parameterized synchronous-read implementation remain future
work.
