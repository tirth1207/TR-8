; STORE uses RD as its source register.
LDI R0, 5
LDI R1, 3
ADD R0, R1
STORE 0x10, R0
LOAD R2, 0x10
HALT
