library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.TR8A32_ISA_PKG.ALL;

entity TR8A32_CSR is
    Port (
        CLK        : in  STD_LOGIC;
        RESET      : in  STD_LOGIC;
        IRQ        : in  STD_LOGIC;
        TRAP_TAKEN : in  STD_LOGIC;
        TRAP_PC    : in  WORD32;
        TRAP_CAUSE : in  WORD32;
        ERET       : in  STD_LOGIC;
        MTVEC      : out WORD32;
        MEPC       : out WORD32;
        MCAUSE     : out WORD32
    );
end TR8A32_CSR;

architecture RTL of TR8A32_CSR is
    signal mtvec_reg : WORD32 := x"00000100";
    signal mepc_reg : WORD32 := (others => '0');
    signal mcause_reg : WORD32 := (others => '0');
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' then
                mtvec_reg <= x"00000100";
                mepc_reg <= (others => '0');
                mcause_reg <= (others => '0');
            elsif TRAP_TAKEN = '1' or IRQ = '1' then
                mepc_reg <= TRAP_PC;
                mcause_reg <= TRAP_CAUSE;
            elsif ERET = '1' then
                mcause_reg <= (others => '0');
            end if;
        end if;
    end process;

    MTVEC <= mtvec_reg;
    MEPC <= mepc_reg;
    MCAUSE <= mcause_reg;
end RTL;
