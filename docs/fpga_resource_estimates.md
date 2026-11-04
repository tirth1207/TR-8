# TR-8-A32N FPGA Resource Plan

No FPGA synthesis has been performed for TR-8-A32N. The values below are
planning estimates, not implementation results.

## Main cost drivers

- 32-bit CPU ALU and register file
- Instruction and data memories
- Four signed INT8 multipliers in the 2x2 NPU
- Four 32-bit accumulators
- NPU local SRAM
- Bus and control FSMs

The 2x2 NPU is intentionally small enough to map to a few FPGA DSP blocks or
to LUT-based multipliers on devices without suitable DSP support. Actual
mapping depends on the selected FPGA, synthesis constraints, multiplier
inference, and memory architecture.

## Measurement plan

For each milestone, record:

- LUT count
- Flip-flop count
- Block RAM count
- DSP count
- Maximum clock frequency
- Worst slack
- Estimated dynamic and static power

First synthesize the CPU alone, then the NPU alone, then the integrated SoC.
Compare 2x2 and 4x4 arrays only after the 2x2 implementation has a verified
resource and timing baseline.

## RAM considerations

The legacy TR-8 RAM uses asynchronous read and full-memory synchronous reset.
That is useful for simulation but may not infer FPGA block RAM. The new NPU
local SRAM should use an FPGA-friendly synchronous-read interface from the
start. A simulation memory model may be retained only when its timing contract
matches the synthesizable implementation.

No FPGA deployment or ASIC fabrication should be claimed until tool reports and
board-level measurements exist.
