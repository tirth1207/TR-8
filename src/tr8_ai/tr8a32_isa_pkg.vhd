library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package TR8A32_ISA_PKG is
    subtype WORD32 is STD_LOGIC_VECTOR(31 downto 0);
    subtype REG_ADDR is STD_LOGIC_VECTOR(4 downto 0);
    type PROGRAM_ARRAY is array (0 to 255) of WORD32;

    constant OP_ALU_REG : STD_LOGIC_VECTOR(5 downto 0) := "000000";
    constant OP_ADDI    : STD_LOGIC_VECTOR(5 downto 0) := "000001";
    constant OP_LW      : STD_LOGIC_VECTOR(5 downto 0) := "000010";
    constant OP_SW      : STD_LOGIC_VECTOR(5 downto 0) := "000011";
    constant OP_BEQ     : STD_LOGIC_VECTOR(5 downto 0) := "000100";
    constant OP_BNE     : STD_LOGIC_VECTOR(5 downto 0) := "000101";
    constant OP_JAL     : STD_LOGIC_VECTOR(5 downto 0) := "000110";
    constant OP_LUI     : STD_LOGIC_VECTOR(5 downto 0) := "000111";
    constant OP_ECALL   : STD_LOGIC_VECTOR(5 downto 0) := "111101";
    constant OP_ERET    : STD_LOGIC_VECTOR(5 downto 0) := "111110";
    constant OP_HALT    : STD_LOGIC_VECTOR(5 downto 0) := "111111";

    constant ALU_ADD : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    constant ALU_SUB : STD_LOGIC_VECTOR(3 downto 0) := "0001";
    constant ALU_AND : STD_LOGIC_VECTOR(3 downto 0) := "0010";
    constant ALU_OR  : STD_LOGIC_VECTOR(3 downto 0) := "0011";
    constant ALU_XOR : STD_LOGIC_VECTOR(3 downto 0) := "0100";
    constant ALU_SLL : STD_LOGIC_VECTOR(3 downto 0) := "0101";
    constant ALU_SRL : STD_LOGIC_VECTOR(3 downto 0) := "0110";
    constant ALU_SRA : STD_LOGIC_VECTOR(3 downto 0) := "0111";
    constant ALU_SLT : STD_LOGIC_VECTOR(3 downto 0) := "1000";
    constant ALU_SLTU: STD_LOGIC_VECTOR(3 downto 0) := "1001";
end TR8A32_ISA_PKG;
