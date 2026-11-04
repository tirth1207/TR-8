# TR-8-A32N NPU Programming Model

The NPU is controlled through memory-mapped registers and uses local SRAM.
This keeps the CPU instruction decoder independent from accelerator details.

## Register map

Base address: `NPU_BASE`

| Offset | Register | Description |
|---:|---|---|
| `0x00` | `CONTROL` | `START`, `RESET`, and operation mode |
| `0x04` | `STATUS` | `BUSY`, `DONE`, `ERROR`, `SATURATED` |
| `0x08` | `ERROR` | Error code |
| `0x0C` | `INPUT_BASE` | Local input SRAM byte offset |
| `0x10` | `WEIGHT_BASE` | Local weight SRAM byte offset |
| `0x14` | `BIAS_BASE` | Local bias SRAM byte offset |
| `0x18` | `OUTPUT_BASE` | Local output SRAM byte offset |
| `0x1C` | `DIMENSIONS` | Encoded M, K, and N dimensions |
| `0x20` | `INPUT_STRIDE` | Input row stride |
| `0x24` | `WEIGHT_STRIDE` | Weight row stride |
| `0x28` | `OUTPUT_STRIDE` | Output row stride |
| `0x2C` | `QUANT_SHIFT` | Output scaling/shift |
| `0x30` | `IRQ_ENABLE` | Completion interrupt enable |
| `0x34` | `PERF_CYCLES` | Operation cycle count |

The current fixed-size controller implements the control, status, error, IRQ
enable, and performance-cycle registers. Base-address, dimension, stride,
quantization, and SRAM registers remain reserved until generalized tensor
addressing is implemented. The current RTL places `DIMENSIONS` at `0x20` to
preserve the existing `C11` output register at `0x1C`.
`QUANT_SHIFT` is implemented at `0x2C` as a five-bit arithmetic right shift
applied before saturation and ReLU.
The current supported dimension value is `0x00020202` (`M=2`, `K=2`, `N=2`);
other values produce an explicit start error until a generalized datapath is
implemented.

## Operation

The first operation computes:

```text
C[m,n] = ReLU(saturate32(sum(A[m,k] * B[k,n]) + bias[n]))
```

Inputs and weights are signed INT8. Accumulation is signed INT32. The output
format and quantization policy must be explicit for every test vector; no
implicit narrowing is permitted.

## Software sequence

1. Wait until `STATUS.BUSY` is clear.
2. Write input, weight, and bias data into local SRAM.
3. Program base offsets, dimensions, strides, and quantization.
4. Write `CONTROL.START`.
5. Poll `STATUS` until `DONE` or `ERROR`.
6. Read output SRAM.
7. Clear completion status according to the final register specification.

Completion interrupts are added after polling is verified. DMA is deferred
until CPU copy overhead has been measured.
