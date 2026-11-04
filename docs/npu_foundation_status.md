# TR-8-A32N NPU Foundation Status

The first NPU datapath milestone contains:

- A signed INT8 multiply-accumulate unit with a 32-bit accumulator.
- A fixed 2x2 matrix engine.
- Per-output signed 32-bit bias addition.
- One-cycle matrix calculation after input capture.
- `START`, `BUSY`, `DONE`, and `ERROR` status behavior.
- Independent assertion-based testbenches.

The current array computes:

```text
C00 = bias0 + A00*B00 + A01*B10
C01 = bias1 + A00*B01 + A01*B11
C10 = bias0 + A10*B00 + A11*B10
C11 = bias1 + A10*B01 + A11*B11
```

This is a fixed-size verification datapath, not yet a programmable accelerator.
Local SRAM, ReLU, saturation/quantization, memory-mapped control registers,
CPU integration, and Python golden-vector comparison are future milestones.

No FPGA resource or timing claims have been made.
