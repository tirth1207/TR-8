# TR-8-A32 CPU ISA

TR-8-A32 uses fixed 32-bit instructions and a byte-addressed 32-bit datapath.
All integer values use two's-complement representation unless an instruction
explicitly defines unsigned comparison or shifting.

## Register set

| Register | ABI role |
|---|---|
| `x0` | Constant zero |
| `x1` | Return address |
| `x2` | Stack pointer |
| `x3` | Global/thread pointer |
| `x4-x7` | Temporaries |
| `x8-x15` | Saved registers |
| `x16-x23` | Arguments/results |
| `x24-x31` | Temporaries/saved registers |

Writes to `x0` are ignored and reads always return zero.

## Instruction formats

Register format:

```text
31..26 25..21 20..16 15..11 10..6 5..0
opcode    rd     rs1    rs2   funct reserved
```

Immediate format:

```text
31..26 25..21 20..16 15..0
opcode    rd     rs1   immediate
```

Branch format:

```text
31..26 25..21 20..16 15..0
opcode   rs1    rs2   signed PC-relative halfword offset
```

The initial implementation uses aligned 32-bit accesses. Misaligned accesses
trap rather than being silently corrected.

## Initial instruction groups

The implemented foundation opcode constants are in
`src/tr8_ai/tr8a32_isa_pkg.vhd`. The current CPU milestone implements the
following subset:

- `ADD`, `SUB`, `AND`, `OR`, `XOR`
- `ADDI`
- `LW`, `SW`
- `BEQ`, `BNE`
- `LUI`
- `HALT`
- `ERET`

The ALU foundation also implements `SLL`, `SRL`, `SRA`, `SLT`, and `SLTU`.
Immediate logical operations, calls, CSR access, traps, interrupts, and
additional branches remain planned work.

The current CPU has a minimal interrupt path: an external `IRQ` sampled at
`FETCH` saves the PC, records timer cause `1`, and jumps to `MTVEC`. `ERET`
returns to `MEPC`. Interrupt masking and software CSR instructions are not yet
implemented.

Reserved opcode space is retained for NPU, vector, atomic, and future system
extensions. NPU configuration remains memory-mapped rather than being encoded
into the base CPU decoder.

## Calls, stack, and traps

`JAL` writes the return address to `x1`. Software uses `x2` as the descending
stack pointer. Trap entry saves the return PC and cause in CSRs and transfers
control to a configured trap vector. `ERET` restores execution.

The first CPU milestone may implement a minimal trap subset before external
interrupts. Interrupt support is not considered complete until timer and NPU
completion sources are independently verified.
