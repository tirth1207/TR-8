library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.TR8_ISA_PKG.ALL;

entity CONTROL_UNIT is
    Port (
        OPCODE     : in  STD_LOGIC_VECTOR(3 downto 0);
        RD         : in  STD_LOGIC_VECTOR(1 downto 0);
        ZERO_FLAG  : in  STD_LOGIC;
        ALU_SEL    : out STD_LOGIC_VECTOR(2 downto 0);
        REG_WE     : out STD_LOGIC;
        REG_WADDR  : out STD_LOGIC_VECTOR(1 downto 0);
        WB_SEL     : out STD_LOGIC_VECTOR(1 downto 0);
        RAM_WE     : out STD_LOGIC;
        JUMP       : out STD_LOGIC;
        HALT       : out STD_LOGIC
    );
end CONTROL_UNIT;

architecture RTL of CONTROL_UNIT is
begin
    process(OPCODE, RD, ZERO_FLAG)
    begin
        ALU_SEL   <= "110";
        REG_WE    <= '0';
        REG_WADDR <= (others => '0');
        WB_SEL    <= "00";
        RAM_WE    <= '0';
        JUMP      <= '0';
        HALT      <= '0';

        case OPCODE is
            when OP_LDI =>
                REG_WE    <= '1';
                WB_SEL    <= "01";
            when OP_ADD =>
                REG_WE    <= '1';
                ALU_SEL   <= "000";
            when OP_SUB =>
                REG_WE    <= '1';
                ALU_SEL   <= "001";
            when OP_AND =>
                REG_WE    <= '1';
                ALU_SEL   <= "010";
            when OP_OR =>
                REG_WE    <= '1';
                ALU_SEL   <= "011";
            when OP_XOR =>
                REG_WE    <= '1';
                ALU_SEL   <= "100";
            when OP_LOAD =>
                REG_WE    <= '1';
                WB_SEL    <= "10";
            when OP_STORE =>
                RAM_WE    <= '1';
            when OP_JMP =>
                JUMP      <= '1';
            when OP_JZ =>
                if ZERO_FLAG = '1' then
                    JUMP <= '1';
                end if;
            when OP_HALT =>
                HALT <= '1';
            when OP_NOT =>
                REG_WE  <= '1';
                ALU_SEL <= "101";
            when others =>
                null;
        end case;

        REG_WADDR <= RD;
    end process;
end RTL;
