# NPU Controller Status

The NPU controller is a memory-mapped peripheral for the fixed 2x2 engine. It
is connected to the TR-8-A32N CPU bus through the SoC memory decoder. Operand
registers are implemented as indexed local tensor storage, keeping the
datapath independent from the CPU bus timing.

The controller is selected by addresses `0x00000100` through `0x000001FF`.

| Offset | Function |
|---:|---|
| `0x00` | Control: bit 0 starts; bit 1 clears DONE/ERROR; bit 2 enables ReLU; bit 3 enables signed 32-bit saturation |
| `0x04` | Status: bit 0 BUSY, bit 1 DONE, bit 2 ERROR |
| `0x08` | Error code: `1` datapath error, `2` start while busy |
| `0x20` | Dimensions: bits 7:0 `M`, 15:8 `K`, 23:16 `N` |
| `0x2C` | Quantization right shift: bits 4:0 |
| `0x10-0x1C` | Outputs C00, C01, C10, C11 |
| `0x80-0x8C` | Input matrix A |
| `0x90-0x9C` | Weight matrix B |
| `0xA0-0xA4` | Bias values |
| `0x30` | IRQ enable: bit 0 |
| `0x34` | Performance cycle counter |

Inputs and weights use the low signed INT8 byte of each word. Biases and outputs
are signed 32-bit values. ReLU clamps negative results to zero, while
saturation clamps widened accumulations to the signed 32-bit range. The
controller rejects an unknown address and records a busy-start error. The CPU integration test programs operands through
load/store transactions, starts the engine, polls status, and reads back
`C00`. Completion `IRQ` is a one-cycle pulse, while DONE remains latched until
software clears it with control bit 1. Local SRAM replacement and larger tensor
transfers are future steps. The current local storage is a four-byte input
region, a four-byte weight region, and a two-word bias region; larger
parameterized SRAM and generalized dimensions remain future steps.

The supported dimension encoding is `0x00020202` (`M=2`, `K=2`, `N=2`).
Unsupported dimensions are rejected on START with error code `3`; this makes
the current fixed datapath limitation explicit.

The quantization shift is a signed arithmetic right shift applied to the
widened accumulator before saturation and ReLU. Reset selects shift zero.

The performance counter increments while the matrix engine is busy. IRQ is
enabled after reset for backward compatibility and can be disabled through
`0x30`.

The Python golden model is
[`tools/tr8a32_npu_reference.py`](../tools/tr8a32_npu_reference.py). It
matches the fixed 2x2 operand layout and verifies bias addition, optional ReLU,
and optional signed 32-bit saturation.
