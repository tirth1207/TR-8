# Module Documentation

- `PROGRAM_COUNTER`: synchronous reset, increment, jump, and hold.
- `INSTRUCTION_ROM`: asynchronous 256 x 16 ROM with a sample program and NOP
  defaults.
- `DATA_RAM`: asynchronous read and synchronous write/reset 256 x 8 RAM.
- `CONTROL_UNIT`: complete combinational decode with defaults on every path.
- `TR8_CPU`: integrates the datapath, registered flag, and registered HALT.
- `ALU` and `REGISTER_FILE`: existing verified modules retained, with register
  debug outputs added for top-level observability.
