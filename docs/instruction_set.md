# Instruction Set

Instructions use `opcode[15:12]`, `RD[11:10]`, `RS[9:8]`, and
`immediate[7:0]`. STORE intentionally uses RD as its source register.
Reserved opcodes D-F are decoded as NOPs.

Register-writing instructions update the committed zero flag: it is one for a
zero write-back value and zero otherwise. NOP, STORE, JMP, JZ, and HALT leave
the flag unchanged.
