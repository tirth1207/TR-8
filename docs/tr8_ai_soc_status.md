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
- A memory-mapped NPU controller at `0x00000100`-`0x000001FF`.
- CPU-driven NPU integration coverage from register programming through result
  readback.
- NPU completion IRQ combined with the timer IRQ at the CPU interrupt input.

The timer exposes a counter at offset `0x0`, compare value at `0x4`, control
at `0x8`, and pending-interrupt clear at `0xC`. Its pending `IRQ` is connected
to the CPU trap input.

The memory map is intentionally minimal. Addresses with bits 31..10 clear
select the initial 1 KiB data window; other data addresses return `ERROR`.
The NPU window is routed to the controller rather than ordinary data RAM.
This is still a single-master interconnect; arbitration and concurrent NPU
memory traffic are not implemented yet. NPU completion is reported as a
one-cycle interrupt pulse, while DONE remains latched for software polling.

The CPU now accepts an IRQ at an instruction-fetch boundary, saves the current
PC in `MEPC`, records cause `1` in `MCAUSE`, jumps to `MTVEC`, and supports
`ERET` return. A full interrupt-enable/masking model and interrupt controller
remain future work.

The timer IRQ is wired to this CPU input in the SoC wrapper. Software must
clear the timer pending bit before returning from the handler; otherwise the
level-sensitive request can cause another trap. The CPU suppresses immediate
interrupt retriggering while an interrupt handler is active.

The memory model is a reference implementation for simulation. FPGA block-RAM
inference and a parameterized synchronous-read implementation remain future
work.

The CPU-driven NPU integration test programs the controller through ordinary
load/store transactions, starts a fixed 2x2 INT8 operation, polls completion,
and reads back `C00`. NPU local SRAM, completion interrupts, and larger tensor
transfers remain future milestones.
