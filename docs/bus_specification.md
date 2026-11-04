# TR-8-A32N Bus Specification

The first data interface is a simple, non-pipelined, single-master transaction interface. The CPU issues one request and waits for a response before issuing the next request.

The current RTL implementation is in `src/tr8_ai/tr8a32_memory.vhd` and `src/tr8_ai/tr8a32_soc.vhd`. It implements 32-bit word transfers only; byte enables are not present in the RTL. The CPU holds its request signals until READY is asserted. A transfer completes on a rising clock edge where VALID and READY are both high. ERROR is meaningful on that completion edge and causes the CPU to enter its trap vector rather than write back invalid load data.

## Request signals

- `DATA_VALID`
- `DATA_WRITE`
- `DATA_ADDR[31:0]`
- `DATA_WDATA[31:0]`

## Response signals

- `DATA_READY`
- `DATA_RDATA[31:0]`
- `DATA_ERROR`

## Implemented address map

| Address range | Purpose |
|---|---|
| `0x00000000-0x000000FF` | Ordinary data RAM window |
| `0x00000100-0x000001FF` | NPU controller and operand registers |
| `0x00000400-0x0000040F` | Timer registers |
| Instruction address space | Separate instruction ROM, byte-addressed with 32-bit words |

Unmapped data addresses return an error. The ordinary RAM window is deliberately limited to avoid overlap with the NPU and timer peripheral windows. Instruction fetches outside the configured ROM range return zero rather than wrapping to another program word.

## Arbitration and memory ownership

Only the CPU is a bus master in the first version. The NPU accesses its local operand storage through its private datapath. A future DMA engine may become a second master, requiring an arbiter and explicit fairness rules.
