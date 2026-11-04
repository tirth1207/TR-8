# TR-8-A32N Bus Specification

The first bus is a simple, non-pipelined, single-master transaction interface.
The CPU issues one request and waits for an acknowledgement before issuing the
next request.

The current RTL implementation is in `src/tr8_ai/tr8a32_memory.vhd` and
`src/tr8_ai/tr8a32_soc.vhd`. It currently implements the CPU-to-data-memory
path and returns an error for addresses outside the initial data window.

## Request signals

- `valid`
- `write`
- `address[31:0]`
- `wdata[31:0]`
- `byte_enable[3:0]`

## Response signals

- `ready`
- `rdata[31:0]`
- `error`

The CPU holds address, direction, write data, and byte enables stable while
`valid` is asserted and `ready` is low. A transfer completes on a clock edge
where both `valid` and `ready` are high.

## Address map

The final addresses are frozen before RTL, but the initial regions are:

| Region | Purpose |
|---|---|
| Instruction memory | CPU instruction fetch |
| CPU data memory | General loads and stores |
| NPU local SRAM window | CPU access to accelerator buffers |
| NPU control window | NPU registers |
| `0x00000400-0x0000040F` | Timer registers |
| CSR/debug window | Status and performance counters |

The decoder must return `error` for unmapped addresses and must not alias
peripheral registers accidentally.

## Arbitration and memory ownership

Only the CPU is a bus master in the first version. The NPU accesses local SRAM
through its private datapath. A future DMA engine may become a second master,
requiring an arbiter and explicit fairness rules.

This arrangement avoids CPU/NPU contention during matrix multiplication while
retaining a simple software-visible model.
