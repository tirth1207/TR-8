# Designing an 8-Bit CPU Without Prior VHDL Experience: An AI-Assisted, Test-Driven Hardware Development Case Study

**Project:** TR-8  
**Repository:** [tirth1207/TR-8](https://github.com/tirth1207/TR-8)  
**Document type:** Technical report / research-paper-style project case study  
**Implementation language:** VHDL-2008  
**Simulation toolchain:** GHDL and GTKWave  
**Status:** Simulation-verified educational RTL design; FPGA synthesis and physical performance are not yet measured

---

## Abstract

This paper documents the design and verification of TR-8, a small 8-bit processor implemented in VHDL-2008 with substantial assistance from generative AI. The project began without the author having prior practical experience writing VHDL. Instead of treating that limitation as a reason not to attempt processor design, the development process used AI as an interactive hardware-design tutor, code-generation assistant, debugging partner, and reviewer. The work was organized around small architectural milestones, explicit instruction semantics, modular RTL, self-checking testbenches, waveform inspection, and iterative correction.

TR-8 is a single-cycle, 8-bit datapath processor with a 16-bit fixed-width instruction format, four 8-bit general-purpose registers, an 8-bit arithmetic and logic unit, a 256-word instruction ROM, a 256-byte data RAM, a program counter, a control unit, a committed zero flag, and a HALT state. Its instruction set contains 13 defined operations: NOP, LDI, ADD, SUB, AND, OR, XOR, LOAD, STORE, JMP, JZ, HALT, and NOT. The design separates the instruction set definition from the processor modules and includes a small Python assembler.

The verification approach uses GHDL for VHDL-2008 analysis, elaboration, and simulation, and GTKWave for inspection of internal signals. The project test suite covers individual modules and CPU-level integration behavior, including arithmetic, logical operations, memory read/write, conditional and unconditional control flow, reset, zero-flag behavior, and HALT stability. A previously reported full test run completed all eight legacy TR-8 testbenches successfully. No FPGA synthesis, place-and-route, maximum clock-frequency, power, or silicon measurements are claimed. Consequently, this report distinguishes architectural capabilities and analytically derived throughput from measured hardware performance.

The central result is methodological: a developer without prior VHDL experience can use AI to help construct and verify a small processor, provided that the developer remains responsible for architecture, requirements, test design, evidence, and technical review. AI-generated RTL is not accepted as correct merely because it compiles; correctness is established through explicit semantics, assertions, simulation, and inspection.

**Keywords:** 8-bit CPU, VHDL-2008, AI-assisted engineering, processor design, digital logic, ALU, instruction set architecture, GHDL, GTKWave, test-driven hardware development.

---

## 1. Introduction

A processor is often treated as an advanced subject that requires extensive prior knowledge of digital design, computer architecture, and a hardware description language. TR-8 was created to explore a different learning path: start with a small, understandable processor architecture and use AI assistance to bridge gaps in language knowledge while retaining engineering responsibility for the design.

The goal was not to ask an AI system to produce a large processor in one prompt. That approach would make it difficult to understand the architecture, locate defects, or establish confidence in the result. Instead, the project was developed incrementally. Individual components were described, implemented, compiled, simulated, and checked before they were integrated into the CPU.

The project had four main objectives:

1. Design a complete educational 8-bit CPU with a defined instruction set.
2. Implement the design as modular, synthesizable-style VHDL-2008 RTL.
3. verify the design using repeatable simulation and self-checking testbenches.
4. Document the architecture and development method so that another learner can reproduce, extend, and critique the work.

The project is educational rather than commercial. It is deliberately small enough that the instruction format, datapath, control signals, and state updates can be inspected without requiring a complex operating system, cache hierarchy, pipeline, or external memory controller.

### 1.1 What “without learning VHDL” means in this project

The title describes the starting point, not a claim that hardware description language knowledge is unnecessary. The author began without practical VHDL experience and relied on AI explanations and generated examples to make progress. During development, the author still had to understand enough of the generated design to decide whether it matched the intended architecture, interpret compiler and simulator errors, inspect waveforms, and challenge incorrect assumptions.

A more precise interpretation is therefore:

> TR-8 demonstrates an AI-assisted route to building a processor before acquiring conventional, formal VHDL expertise—not a route that removes the need to understand hardware behavior.

This distinction matters. VHDL describes concurrent hardware, not ordinary sequential software. A design can compile and still have incorrect timing, unintended latches, multiple drivers, invalid reset behavior, or an architecture that does not match its documentation.

---

## 2. Development Methodology

### 2.1 AI as a development partner

AI assistance was used in several roles:

- **Tutor:** explaining entities, architectures, signals, processes, sensitivity lists, packages, numeric types, and clocked logic.
- **Architectural assistant:** translating a proposed CPU into modules, instruction fields, control signals, and execution rules.
- **Code-generation assistant:** producing initial VHDL modules and testbench scaffolding.
- **Debugging assistant:** interpreting GHDL errors, assertion failures, and waveform observations.
- **Review assistant:** checking consistency between the ISA, control unit, datapath, testbenches, assembler, and documentation.
- **Documentation assistant:** maintaining an understandable description of the architecture and verification process.

AI output was treated as a proposal to be tested, not as authoritative hardware design.

### 2.2 Incremental, test-driven workflow

The project followed a repeated cycle:

1. State the intended behavior in plain language.
2. Define inputs, outputs, bit widths, reset behavior, and timing expectations.
3. Ask AI to explain or draft a small RTL module.
4. Inspect the source and compare it with the intended behavior.
5. Compile with GHDL using VHDL-2008.
6. Run a dedicated testbench.
7. Inspect important signals in GTKWave when behavior is unclear.
8. Correct the RTL or testbench and rerun the tests.
9. Integrate the module only after its local behavior is understood.

The workflow reduced the size of each debugging problem. For example, an ALU failure could be isolated from program-counter or memory behavior by testing the ALU independently.

### 2.3 Toolchain

| Tool | Role |
|---|---|
| VHDL-2008 | Hardware description language |
| GHDL | Analysis, elaboration, and simulation |
| GTKWave | Waveform inspection |
| Python | Small assembler utility |
| Git and GitHub | Version control, change history, and collaboration |

GHDL and GTKWave are simulation and waveform tools. Their use does not by itself prove that the design fits or operates at a particular speed on an FPGA or ASIC.

---

## 3. TR-8 Architecture

### 3.1 Architectural summary

TR-8 is an 8-bit, single-cycle processor. Its major architectural parameters are:

| Parameter | TR-8 implementation |
|---|---:|
| Data width | 8 bits |
| Address / program-counter width | 8 bits |
| Instruction width | 16 bits |
| Instruction storage | 256 × 16-bit words |
| Data storage | 256 × 8-bit bytes |
| General-purpose registers | 4 |
| Width of each general-purpose register | 8 bits |
| ALU result width | 8 bits |
| Opcode width | 4 bits |
| Destination register field | 2 bits |
| Source register field | 2 bits |
| Immediate field | 8 bits |
| Execution organization | Single-cycle |
| Reset | Active-high, synchronous |
| HALT | Architectural halted state |

The design has a small address space by intention. The 8-bit program counter addresses 256 instruction words. The data RAM has 256 byte locations addressed by an 8-bit address.

### 3.2 High-level datapath

The processor connects the following functional blocks:

- Program counter
- Instruction ROM
- Instruction field decoder
- Control unit
- Four-register register file
- ALU
- Data RAM
- Write-back selection logic
- Zero-flag state
- HALT state

The program counter selects an instruction from ROM. The instruction fields select register operands and control behavior. The ALU performs arithmetic or logical operations. The write-back multiplexer selects an immediate, RAM read value, or ALU result for the destination register. The data RAM supports LOAD and STORE. The control unit selects jumps, conditional jumps, register writes, memory writes, and HALT behavior.

### 3.3 Instruction format

Every instruction is 16 bits wide:

```text
15             12 11       10 9         8 7                  0
+----------------+-----------+-----------+--------------------+
|     OPCODE     |    RD     |    RS     |     IMMEDIATE      |
+----------------+-----------+-----------+--------------------+
      4 bits        2 bits      2 bits          8 bits
```

- **OPCODE:** selects the instruction.
- **RD:** identifies the destination register, or the register used by STORE.
- **RS:** identifies the second register operand for two-register operations.
- **IMMEDIATE:** provides an 8-bit constant, memory address, or jump target depending on the instruction.

The shared package `src/tr8_isa_pkg.vhd` defines the instruction encodings and an `encode` helper function. This avoids duplicating raw opcode values throughout the design and testbenches.

### 3.4 Register file

The processor contains four general-purpose 8-bit registers:

- R0
- R1
- R2
- R3

The register file has two asynchronous read ports and one synchronous write port. The destination register is selected by a 2-bit address. On a rising clock edge, a write occurs when write enable is asserted, unless synchronous reset is active. Reset clears all four registers.

Two read ports allow the ALU to receive two register operands without adding a separate register-read cycle. This is one of the design choices that supports the single-cycle execution model.

### 3.5 Arithmetic and Logic Unit

The ALU accepts two 8-bit inputs and a 3-bit operation selector. Its defined functions are:

| ALU selector | Operation | Result |
|---|---|---|
| `000` | Addition | A + B |
| `001` | Subtraction | A − B |
| `010` | AND | A AND B |
| `011` | OR | A OR B |
| `100` | XOR | A XOR B |
| `101` | NOT | NOT A |
| `110` | Pass A | A |
| `111` | Pass B | B |

The ALU output is 8 bits. Addition and subtraction therefore retain the low eight result bits. In unsigned arithmetic, values beyond the range 0 to 255 wrap modulo 256. For example:

[
250 + 10 = 260 equiv 4 pmod{256}
]

This is normal fixed-width behavior, not an indication that the processor has a wider result register. The current ALU exposes a ZERO output that is asserted when the result equals zero.

### 3.6 Program counter

The program counter is 8 bits wide. On a rising clock edge:

- Synchronous reset sets it to zero.
- If enabled and a jump is selected, it loads the 8-bit jump target.
- Otherwise, it increments by one.
- When disabled, it holds its current value.

Because the instruction ROM is word-indexed and each instruction is one 16-bit word, the PC increments by one instruction index, not by two byte addresses.

### 3.7 Instruction ROM and data RAM

**Instruction ROM:** 256 entries, each 16 bits wide. The ROM is asynchronous-read in the current implementation and accepts a program through a VHDL generic. This allows testbenches to instantiate the CPU with different programs without editing the processor RTL.

**Data RAM:** 256 entries, each 8 bits wide. It has a synchronous write port and an asynchronous read output. LOAD selects the RAM output for register write-back; STORE writes the selected source register to the immediate address.

The current asynchronous-read RAM is convenient for the reference single-cycle simulation model. FPGA memory inference is target- and tool-dependent, and this implementation has not been shown to infer a block RAM.

---

## 4. Instruction Set Architecture

TR-8 defines 13 instruction operations.

| Opcode | Mnemonic | Operation / behavior |
|---|---|---|
| `0000` | NOP | No architectural operation |
| `0001` | LDI | Load 8-bit immediate into RD |
| `0010` | ADD | RD ← RD + RS |
| `0011` | SUB | RD ← RD − RS |
| `0100` | AND | RD ← RD AND RS |
| `0101` | OR | RD ← RD OR RS |
| `0110` | XOR | RD ← RD XOR RS |
| `0111` | LOAD | RD ← RAM[immediate] |
| `1000` | STORE | RAM[immediate] ← RD |
| `1001` | JMP | PC ← immediate |
| `1010` | JZ | Jump when the committed zero flag is set |
| `1011` | HALT | Enter halted state |
| `1100` | NOT | RD ← NOT RD |

The remaining opcode values are reserved and follow the control unit's default no-operation behavior.

### 4.1 Instruction semantics

**LDI RD, imm** writes the immediate byte to the selected register.

**ADD RD, RS** adds the current RD and RS values and writes the low eight bits to RD.

**SUB RD, RS** subtracts RS from RD and writes the low eight bits to RD.

**AND, OR, XOR** apply the corresponding bitwise operation to RD and RS and write the result to RD.

**NOT RD** inverts all bits of RD and writes the result back to RD.

**LOAD RD, address** reads one byte from the data RAM at the immediate address and writes it to RD.

**STORE address, RD** writes the contents of RD to the immediate RAM address. The source is RD; RS is not used for STORE.

**JMP address** loads the program counter with the immediate address.

**JZ address** loads the program counter with the immediate address only when the committed zero flag is set. Otherwise, normal PC progression occurs.

**HALT** enters a persistent halted state. The PC and architectural write activity are held until reset.

**NOP** leaves architectural state unchanged apart from normal instruction progression.

### 4.2 Zero-flag behavior

The CPU maintains a registered zero flag. It is updated when an instruction that writes a register commits its write-back result. It is not simply a continuously changing view of the current ALU output.

This distinction makes JZ use the previously committed result state. It also means operations that do not write a register—such as STORE, JMP, JZ, NOP, and HALT—do not independently replace the committed zero flag.

---

## 5. Example Program and Expected Result

The default sample program is:

```asm
LDI   R0, 5
LDI   R1, 3
ADD   R0, R1
STORE 0x10, R0
HALT
```

Its machine-code representation is:

| Program index | Machine code | Instruction |
|---:|---:|---|
| 0 | `1005` | LDI R0, 5 |
| 1 | `1403` | LDI R1, 3 |
| 2 | `2100` | ADD R0, R1 |
| 3 | `8010` | STORE 0x10, R0 |
| 4 | `B000` | HALT |

Expected architectural result:

| State | Expected value |
|---|---:|
| R0 | `0x08` |
| R1 | `0x03` |
| RAM[`0x10`] | `0x08` |
| HALTED | 1 |
| PC | `0x04` |
| ZERO | 0 |

The example demonstrates immediate loading, register-register arithmetic, data-memory write, and processor halt.

---

## 6. Assembler and Software Support

The repository includes `tools/tr8_assembler.py`, a Python assembler for the TR-8 instruction set. It parses readable assembly instructions, checks register names and immediate ranges, encodes the instruction fields, and prints a listing containing the instruction index, machine word, and source instruction.

Example invocation:

```bat
python tools\tr8_assembler.py programs\store_load.asm
```

The assembler supports the documented instruction mnemonics and provides a small software-development path for writing programs without manually calculating 16-bit instruction encodings.

The assembler is a convenience tool; it does not change the hardware architecture or provide a runtime loader. The CPU's ROM contents are supplied through the VHDL generic at elaboration/simulation time.

---

## 7. Verification Strategy and Results

### 7.1 Unit-level verification

The legacy verification suite contains dedicated testbenches for:

- AND gate
- ALU
- Register file
- Program counter
- Instruction ROM
- Data RAM
- Control unit
- CPU integration

Unit tests isolate local functionality. The CPU integration test then checks whether the modules cooperate correctly under an instruction sequence.

### 7.2 CPU integration coverage

The CPU integration program exercises:

- Synchronous reset and restart
- LDI immediate writes
- ADD and SUB
- AND, OR, XOR, and NOT
- STORE followed by LOAD read-back
- JZ taken and not taken
- JMP
- NOP
- 8-bit overflow and underflow behavior
- Committed zero-flag behavior
- HALT and stability of architectural state after HALT

The integration test includes assertions for register values, RAM read-back, the final PC, the zero flag, and halted-state stability.

### 7.3 Reported simulation evidence

A full run of the legacy `test_all.bat` suite was previously reported with the following outcomes:

| Testbench | Reported result |
|---|---|
| TB_AND_GATE | Passed |
| TB_ALU | Passed |
| TB_REGISTER_FILE | Passed |
| TB_PROGRAM_COUNTER | Passed |
| TB_INSTRUCTION_ROM | Passed |
| TB_DATA_RAM | Passed |
| TB_CONTROL_UNIT | Passed |
| TB_TR8_CPU | Passed |

The CPU integration test reported:

```text
ALL TR-8 CPU INTEGRATION TESTS PASSED!
All TR-8 tests passed.
```

The same run printed time-zero `NUMERIC_STD.TO_INTEGER: metavalue detected` warnings in the CPU test. The assertions completed successfully, but the warnings should be treated as a verification cleanup item rather than hidden or dismissed. A robust follow-up should trace each unresolved input to its source and initialize or constrain it appropriately.

This report records the previously supplied simulation output. It is not a claim that the author of this document independently reran the test suite at publication time. For reproducibility, readers should clone the repository and run the scripts against the exact commit they evaluate.

### 7.4 Reproduction commands

From the repository root on a system with GHDL installed:

```bat
compile.bat
test_all.bat
```

For waveform generation:

```bat
simulate_cpu.bat
```

The simulation script produces a GHW waveform file for GTKWave. Internal signals can be inspected under the CPU instance, including PC, instruction, decoded fields, ALU operands, ALU result, register write-back, RAM activity, zero flag, and HALTED.

### 7.5 What simulation does and does not establish

Passing RTL simulation provides evidence that the tested input sequences produce the expected simulated behavior. It does not, by itself, establish:

- Maximum clock frequency
- FPGA resource utilization
- ASIC gate count
- Power consumption
- Timing closure
- Physical correctness after place-and-route
- Compatibility with a particular FPGA board
- Formal equivalence or exhaustive correctness for all possible programs

Those require additional tools, target constraints, and experiments.

---

## 8. Performance Analysis

### 8.1 Architectural throughput

TR-8 is designed as a single-cycle processor. Each ordinary instruction is intended to complete its architectural work in one active clock cycle. The PC advances by one instruction index for normal progression, while jumps replace the next PC value.

If the implementation is operated at a clock frequency (f), its ideal instruction throughput for a stream of ordinary, non-stalled instructions is:

[
	ext{Ideal throughput} approx f 	ext{ instructions/second}
]

Its ideal average cycles per instruction is:

[
	ext{CPI} approx 1
]

These are architectural expectations, not measured performance results. They assume that the clock period is long enough for the complete combinational path, including instruction decode, register read, ALU operation, memory read where applicable, and write-back selection.

### 8.2 Why no MHz figure is reported

A processor's maximum frequency cannot be inferred from its bit width or from successful simulation. It depends on the longest timing path, the target FPGA or ASIC technology, synthesis mapping, placement, routing, loading, and timing constraints.

The current project has no documented FPGA synthesis and timing report. Therefore, it would be misleading to claim a maximum frequency, a benchmark score, or a measured speed advantage.

### 8.3 Expected critical path

A likely critical path in this single-cycle architecture is:

[
	ext{Instruction ROM}
ightarrow 	ext{Decode/control}
ightarrow 	ext{Register read}
ightarrow 	ext{ALU}
ightarrow 	ext{Write-back}
]

LOAD may have a longer path because it includes the asynchronous data RAM read and the write-back selection logic:

[
	ext{Instruction}
ightarrow 	ext{Address selection}
ightarrow 	ext{Data RAM read}
ightarrow 	ext{Write-back mux}
ightarrow 	ext{Register input}
]

The actual critical path must be determined by synthesis and static timing analysis on a chosen target.

### 8.4 Memory and logic capacity

The declared storage capacity is:

- Instruction ROM: (256 	imes 16 = 4096) bits = 512 bytes.
- Data RAM: (256 	imes 8 = 2048) bits = 256 bytes.
- General-purpose registers: (4 	imes 8 = 32) bits = 4 bytes.

These are logical storage capacities, not FPGA resource counts. Synthesis may map storage into LUTs, flip-flops, distributed RAM, or block RAM depending on the target and coding style.

### 8.5 A benchmark plan for future measured performance

To publish measured performance, a future evaluation should record:

| Metric | How to obtain it | Current status |
|---|---|---|
| Maximum clock frequency | Synthesis and static timing analysis | Not measured |
| LUT / logic-cell count | FPGA synthesis report | Not measured |
| Flip-flop count | FPGA synthesis report | Not measured |
| Block RAM usage | FPGA synthesis report | Not measured |
| DSP usage | FPGA synthesis report | Not measured |
| Dynamic/static power | Vendor power analysis or board measurement | Not measured |
| CPI | Instruction/cycle counter or simulation trace | Architecturally intended near 1 for this single-cycle core |
| Program execution cycles | Cycle-counting testbench | Not published as a benchmark set |
| Area-delay product | Synthesis area × critical-path delay | Not measured |

A fair comparison with another CPU would require the same FPGA, synthesis tool and version, timing constraints, optimization settings, and benchmark workload.

---

## 9. Design Trade-offs and Limitations

### 9.1 Why a small single-cycle CPU?

A single-cycle design makes the relationship between instruction semantics and datapath control relatively direct. It avoids pipeline hazards, forwarding, branch prediction, and multi-stage control complexity. This is useful for learning and for demonstrating the core CPU building blocks.

The trade-off is that the clock period must accommodate the slowest instruction path. A multi-cycle design could use shorter clock periods by spreading work across cycles, while a pipelined design could increase instruction throughput at the cost of more complex control and hazard handling.

### 9.2 Limited register count and address space

Four 8-bit registers and 256 locations of instruction/data addressing are sufficient for small demonstrations but are restrictive for larger programs. The immediate field and 8-bit program counter also limit code organization and control-flow reach.

### 9.3 Asynchronous memory reads

The ROM and RAM use asynchronous read behavior in the current reference design. This supports the simple single-cycle organization but can make FPGA block-memory inference more difficult. A target-specific synchronous memory implementation may require changes to the execution timing and should be treated as a new architecture variant.

### 9.4 No pipeline or interrupts

TR-8 is not pipelined and does not implement interrupts, privilege levels, virtual memory, caches, DMA, or a peripheral bus. Those features are outside the scope of this 8-bit educational CPU.

### 9.5 Simulation versus physical implementation

The repository's simulation results are meaningful for the tested RTL behavior, but hardware implementation requires synthesis, constraints, timing analysis, and preferably board-level validation. This report intentionally does not present unmeasured physical metrics.

---

## 10. Lessons from AI-Assisted Hardware Development

### 10.1 A specification is more important than a large prompt

The most useful input to an AI coding assistant is not simply “build a CPU.” It is a precise description of bit widths, instruction formats, reset behavior, register semantics, memory timing, and expected test cases.

When requirements are ambiguous, AI can generate internally inconsistent modules that look plausible in isolation. A shared ISA package and explicit module interfaces reduce this risk.

### 10.2 Hardware must be tested at multiple levels

A successful compile only shows that the source passed language analysis and elaboration. It does not prove that the CPU performs the correct operation. Unit testbenches, integration tests, assertions, and waveform inspection provide progressively stronger evidence.

### 10.3 The developer remains accountable

AI can explain VHDL syntax and produce useful code quickly, but it may also invent interfaces, misunderstand timing, omit edge cases, or write testbenches that reproduce the same mistaken assumptions as the RTL. The developer must inspect the architecture, challenge generated code, and require independent evidence.

### 10.4 Iterative progress beats one-shot generation

Building and testing the ALU, register file, program counter, memory, and control unit separately made the final integration problem more manageable. The approach also created reusable artifacts: an ISA package, testbenches, an assembler, build scripts, and documentation.

---

## 11. Future Work

The next development stages should prioritize measurable correctness and hardware implementation:

1. Remove or explain all simulation metavalue warnings.
2. Expand directed and randomized instruction-level tests.
3. Add a reference-model or instruction-level scoreboard for differential checking.
4. Add assertions for legal control combinations and architectural invariants.
5. Run a VHDL synthesis flow for a named FPGA target.
6. Record LUT, flip-flop, RAM, and timing reports.
7. Implement a synchronous-memory variant suitable for block RAM.
8. Test the processor on a physical FPGA board.
9. Add a small benchmark suite and publish exact cycle counts.
10. Consider a multi-cycle or pipelined successor only after the baseline has reproducible measurements.

---

## 12. Conclusion

TR-8 demonstrates a practical path from an initial idea to a modular, simulated 8-bit CPU using AI assistance despite the author's lack of prior practical VHDL experience. The result is a processor with a defined 16-bit instruction format, four 8-bit registers, an 8-bit ALU, instruction ROM, data RAM, control unit, program counter, zero flag, and HALT state. It supports arithmetic, bitwise logic, memory access, jumps, conditional jumps, and a small assembler.

The project's strongest contribution is not a claim of high speed or hardware superiority. It is the documented engineering process: decompose a processor into understandable modules, specify behavior before implementation, use AI to accelerate learning and code drafting, and verify each stage with simulation and inspection.

The architecture is single-cycle and therefore has an ideal CPI near one for ordinary instructions, but no maximum clock frequency, FPGA utilization, power, or physical benchmark has yet been established. Those measurements are essential next steps before making claims about real hardware performance.

The broader lesson is that AI can lower the entry barrier to hardware engineering. It does not eliminate the need for engineering judgment. The most effective workflow combines AI's ability to explain and generate with the developer's responsibility to define, test, inspect, and prove.

---

## Reproducibility and Project Links

- **Source repository:** https://github.com/tirth1207/TR-8
- **CPU top-level:** `src/tr8_cpu.vhd`
- **ISA package:** `src/tr8_isa_pkg.vhd`
- **ALU:** `src/alu.vhd`
- **Register file:** `src/register_file.vhd`
- **Control unit:** `src/control_unit.vhd`
- **Program counter:** `src/program_counter.vhd`
- **Instruction ROM:** `src/instruction_rom.vhd`
- **Data RAM:** `src/data_ram.vhd`
- **CPU integration testbench:** `tb/tb_tr8_cpu.vhd`
- **Assembler:** `tools/tr8_assembler.py`
- **Verification report:** `docs/verification_report.md`
- **FPGA implementation notes:** `docs/fpga_implementation.md`

## Publication Note

This document is a research-paper-style engineering case study. Before submitting it to a formal academic venue, add the exact repository commit hash, date and version of GHDL/GTKWave, the full simulation log, target FPGA and synthesis reports if available, and any required institutional or publication formatting. Do not describe the design as FPGA-tested or quote a clock frequency until those experiments have actually been completed.
