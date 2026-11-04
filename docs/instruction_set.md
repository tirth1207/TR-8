# Instruction Set

Instructions use `opcode[15:12]`, `RD[11:10]`, `RS[9:8]`, and
`immediate[7:0]`. STORE intentionally uses RD as its source register.
Reserved opcodes D-F are decoded as NOPs.

The authoritative VHDL definitions and `encode` function are in
`src/tr8_isa_pkg.vhd`. For example, `STORE 0x10, R0` encodes as `8010`
and `LOAD R2, 0x10` encodes as `7810`; the register field is bits 11..10.

Register-writing instructions update the committed zero flag: it is one for a
zero write-back value and zero otherwise. NOP, STORE, JMP, JZ, and HALT leave
the flag unchanged.
