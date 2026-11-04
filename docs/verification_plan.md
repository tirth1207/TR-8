# TR-8-A32N Verification Plan

Verification proceeds in layers. A later layer cannot be declared complete
until the preceding layer passes.

## CPU unit verification

- 32-bit ALU operations and carry/overflow behavior
- Register-file two-read/one-write timing
- `x0` hardwired-zero behavior
- Immediate generation and sign extension
- Branch comparison and target calculation
- Load/store alignment and byte enables
- CSR access and reset values

## CPU integration verification

- Instruction fetch and multi-cycle sequencing
- Calls, returns, and stack-pointer updates
- Branch taken and not taken
- Illegal instruction traps
- Memory boundary and unmapped-address errors
- Timer interrupts and trap return
- Debug counter correctness

## NPU verification

- Signed INT8 multiplication
- Single MAC accumulation
- INT32 overflow policy
- ReLU and saturation
- 2x2 matrix multiplication
- Stride and base-address handling
- Busy/start rejection
- Invalid dimensions
- Reset during operation
- Completion and error status
- Optional interrupt generation

## Reference-model verification

Python produces golden vectors for:

- MAC operations
- Matrix multiplication
- Bias addition
- ReLU
- Quantization and saturation

The VHDL testbench compares every output element, status bit, and error case
against those vectors. Random tests must include zero, positive maximum,
negative minimum, overflow, and dimension-boundary cases.

## Exit criteria

1. All unit assertions pass.
2. CPU executes a memory-mapped peripheral program.
3. NPU output matches the Python model for fixed vectors.
4. CPU starts the NPU and reads a verified output.
5. Polling is stable before interrupts are enabled.
6. Synthesis reports are available before making FPGA resource claims.
