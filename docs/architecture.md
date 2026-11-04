# TR-8 Architecture

TR-8 uses a single-cycle datapath. The current PC selects a 16-bit ROM word.
The instruction fields drive asynchronous register reads and the combinational
control unit. The ALU or RAM supplies the write-back value, and all state
changes occur on the following rising clock edge.

The PC chooses jump address over increment. A HALT instruction disables PC,
register, and RAM writes and sets the registered halted state. Synchronous
reset clears the PC, register file, RAM, zero flag, and halted state.
