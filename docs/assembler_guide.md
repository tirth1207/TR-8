# Assembler Guide

The assembler is [`tools/tr8_assembler.py`](../tools/tr8_assembler.py). Run:

```text
python tools\tr8_assembler.py programs\store_load.asm
python tools\tr8_assembler.py programs\store_load.asm -o store_load.lst
```

It accepts decimal and hexadecimal immediates, validates registers and
operands, strips semicolon comments, and prints an address/machine-code
listing. The assembler follows `src/tr8_isa_pkg.vhd`; for the documented
sample, `STORE 0x10, R0` is `8010` and `LOAD R2, 0x10` is `7810`.
