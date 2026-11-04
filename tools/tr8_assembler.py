#!/usr/bin/env python3
"""Assemble TR-8 instructions using the documented 16-bit encoding."""

import argparse
import re
import sys

OPCODES = {
    "NOP": 0x0, "LDI": 0x1, "ADD": 0x2, "SUB": 0x3,
    "AND": 0x4, "OR": 0x5, "XOR": 0x6, "LOAD": 0x7,
    "STORE": 0x8, "JMP": 0x9, "JZ": 0xA, "HALT": 0xB, "NOT": 0xC,
}
REGISTER_RE = re.compile(r"R([0-3])$", re.IGNORECASE)


def register(token, line_number):
    match = REGISTER_RE.fullmatch(token.strip())
    if not match:
        raise ValueError(f"line {line_number}: invalid register '{token}'")
    return int(match.group(1))


def immediate(token, line_number):
    try:
        value = int(token.strip(), 0)
    except ValueError as exc:
        raise ValueError(f"line {line_number}: invalid immediate '{token}'") from exc
    if not 0 <= value <= 0xFF:
        raise ValueError(f"line {line_number}: immediate must be in 0..255")
    return value


def encode(text, line_number):
    fields = text.replace(",", " ").split()
    if not fields:
        return None
    mnemonic = fields[0].upper()
    if mnemonic not in OPCODES:
        raise ValueError(f"line {line_number}: unknown instruction '{fields[0]}'")
    opcode = OPCODES[mnemonic]
    rd = rs = imm = 0
    if mnemonic == "LDI":
        if len(fields) != 3:
            raise ValueError(f"line {line_number}: LDI requires RD, immediate")
        rd, imm = register(fields[1], line_number), immediate(fields[2], line_number)
    elif mnemonic in {"ADD", "SUB", "AND", "OR", "XOR"}:
        if len(fields) != 3:
            raise ValueError(f"line {line_number}: {mnemonic} requires RD, RS")
        rd, rs = register(fields[1], line_number), register(fields[2], line_number)
    elif mnemonic == "NOT":
        if len(fields) != 2:
            raise ValueError(f"line {line_number}: NOT requires RD")
        rd = register(fields[1], line_number)
    elif mnemonic == "LOAD":
        if len(fields) != 3:
            raise ValueError(f"line {line_number}: LOAD requires RD, address")
        rd, imm = register(fields[1], line_number), immediate(fields[2], line_number)
    elif mnemonic == "STORE":
        if len(fields) != 3:
            raise ValueError(f"line {line_number}: STORE requires address, RD")
        imm, rd = immediate(fields[1], line_number), register(fields[2], line_number)
    elif mnemonic in {"JMP", "JZ"}:
        if len(fields) != 2:
            raise ValueError(f"line {line_number}: {mnemonic} requires address")
        imm = immediate(fields[1], line_number)
    elif len(fields) != 1:
        raise ValueError(f"line {line_number}: {mnemonic} takes no operands")
    return (opcode << 12) | (rd << 10) | (rs << 8) | imm


def assemble(source):
    listing = []
    address = 0
    for line_number, raw_line in enumerate(source.splitlines(), 1):
        text = raw_line.split(";", 1)[0].strip()
        if not text:
            continue
        word = encode(text, line_number)
        if address > 255:
            raise ValueError(f"line {line_number}: program exceeds 256 words")
        listing.append((address, word, text))
        address += 1
    return listing


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", help="assembly source file")
    parser.add_argument("-o", "--output", help="machine-code output file")
    args = parser.parse_args()
    try:
        with open(args.input, encoding="utf-8") as source_file:
            listing = assemble(source_file.read())
        lines = [f"{address:02X}: {word:04X}  {text}"
                 for address, word, text in listing]
        output = "\n".join(lines) + ("\n" if lines else "")
        if args.output:
            with open(args.output, "w", encoding="utf-8", newline="\n") as output_file:
                output_file.write(output)
        else:
            sys.stdout.write(output)
    except (OSError, ValueError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
