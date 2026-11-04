library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package TR8_ISA_PKG is
    subtype WORD16 is STD_LOGIC_VECTOR(15 downto 0);
    subtype BYTE is STD_LOGIC_VECTOR(7 downto 0);
    type ROM_ARRAY is array (0 to 255) of WORD16;

    constant OP_NOP   : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    constant OP_LDI   : STD_LOGIC_VECTOR(3 downto 0) := "0001";
    constant OP_ADD   : STD_LOGIC_VECTOR(3 downto 0) := "0010";
    constant OP_SUB   : STD_LOGIC_VECTOR(3 downto 0) := "0011";
    constant OP_AND   : STD_LOGIC_VECTOR(3 downto 0) := "0100";
    constant OP_OR    : STD_LOGIC_VECTOR(3 downto 0) := "0101";
    constant OP_XOR   : STD_LOGIC_VECTOR(3 downto 0) := "0110";
    constant OP_LOAD  : STD_LOGIC_VECTOR(3 downto 0) := "0111";
    constant OP_STORE : STD_LOGIC_VECTOR(3 downto 0) := "1000";
    constant OP_JMP   : STD_LOGIC_VECTOR(3 downto 0) := "1001";
    constant OP_JZ    : STD_LOGIC_VECTOR(3 downto 0) := "1010";
    constant OP_HALT  : STD_LOGIC_VECTOR(3 downto 0) := "1011";
    constant OP_NOT   : STD_LOGIC_VECTOR(3 downto 0) := "1100";

    function encode(
        opcode : STD_LOGIC_VECTOR(3 downto 0);
        rd : STD_LOGIC_VECTOR(1 downto 0);
        rs : STD_LOGIC_VECTOR(1 downto 0);
        immediate : BYTE
    ) return WORD16;

    constant SAMPLE_PROGRAM : ROM_ARRAY;
end TR8_ISA_PKG;

package body TR8_ISA_PKG is
    function encode(
        opcode : STD_LOGIC_VECTOR(3 downto 0);
        rd : STD_LOGIC_VECTOR(1 downto 0);
        rs : STD_LOGIC_VECTOR(1 downto 0);
        immediate : BYTE
    ) return WORD16 is
    begin
        return opcode & rd & rs & immediate;
    end function;

    constant SAMPLE_PROGRAM : ROM_ARRAY := (
        0 => encode(OP_LDI, "00", "00", x"05"),
        1 => encode(OP_LDI, "01", "00", x"03"),
        2 => encode(OP_ADD, "00", "01", x"00"),
        3 => encode(OP_STORE, "00", "00", x"10"),
        4 => encode(OP_HALT, "00", "00", x"00"),
        others => x"0000"
    );
end TR8_ISA_PKG;
