# FPGA Implementation Notes

The design uses synthesizable VHDL-2008 constructs, but no FPGA synthesis run
has been performed in this environment. The data RAM has asynchronous read and
a full synchronous reset loop. That is convenient for deterministic
simulation, but many FPGA tools cannot infer a block RAM for this combination.

For a target FPGA, a synthesis-specific RAM variant may use synchronous read,
initialization constraints, or a reset policy that clears memory through a
startup procedure. Such a change would alter the single-cycle timing contract
and should be introduced as an explicitly selected architecture, not silently
substituted for this reference model.
