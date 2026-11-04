# TR-8-A32N NPU Programming Model

The current NPU is a fixed 2x2 signed INT8 matrix engine controlled through a memory-mapped register block. It is not yet a generalized tensor accelerator and does not use parameterized SRAM or DMA.

## Implemented register map

Base address: `0x00000100`

| Offset | Register | Description |
|---:|---|---|
| `0x00` | `CONTROL` | bit 0 START; bit 1 clear DONE/ERROR; bit 2 ReLU; bit 3 signed saturation |
| `0x04` | `STATUS` | bit 0 BUSY; bit 1 DONE; bit 2 ERROR |
| `0x08` | `ERROR_CODE` | Error code |
| `0x10-0x1C` | `C00-C11` | Four signed 32-bit outputs |
| `0x20` | `DIMENSIONS` | M in bits 7:0, K in 15:8, N in 23:16 |
| `0x2C` | `QUANT_SHIFT` | Five-bit arithmetic right shift |
| `0x30` | `IRQ_ENABLE` | bit 0 enables completion interrupt |
| `0x34` | `PERF_CYCLES` | Busy-cycle performance counter |
| `0x80-0x8C` | `INPUTS` | Four signed INT8 values, low byte of each word |
| `0x90-0x9C` | `WEIGHTS` | Four signed INT8 values, low byte of each word |
| `0xA0-0xA4` | `BIASES` | Two signed 32-bit bias values |

The only supported dimensions are `0x00020202` (M=2, K=2, N=2). Unsupported dimensions are rejected with error code 3. Error code 1 denotes a datapath error; code 2 denotes START while busy. The implementation has four input words, four weight words, and two bias words of local operand storage. Base-address and stride registers from the future generalized programming model are not implemented.

## Operation

```text
C[m,n] = sum(A[m,k] * B[k,n]) + bias[n]
```

Inputs and weights are signed INT8. Products accumulate with the signed 32-bit bias in a widened intermediate. The optional arithmetic right shift is applied before signed 32-bit saturation; optional ReLU is applied after saturation. With saturation disabled, narrowing follows the RTL's low 32-bit result behavior.

## Software sequence

1. Wait until STATUS.BUSY is clear.
2. Write four input values, four weight values, and two biases.
3. Write DIMENSIONS = 0x00020202.
4. Program QUANT_SHIFT and CONTROL activation bits.
5. Set CONTROL.START.
6. Poll STATUS until DONE or ERROR.
7. Read C00-C11.
8. Clear DONE/ERROR with CONTROL bit 1 before the next operation.

Completion IRQ is a one-cycle pulse when IRQ_ENABLE is set; DONE remains latched until cleared. Software should clear the peripheral completion state before returning from an interrupt handler. Larger tensors, parameterized SRAM, generalized strides, DMA, and richer quantization are future work.
