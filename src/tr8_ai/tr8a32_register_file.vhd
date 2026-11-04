library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.TR8A32_ISA_PKG.ALL;

entity TR8A32_REGISTER_FILE is
    Port (
        CLK   : in  STD_LOGIC;
        RESET : in  STD_LOGIC;
        WE    : in  STD_LOGIC;
        WADDR : in  REG_ADDR;
        WDATA : in  WORD32;
        RADDR1: in  REG_ADDR;
        RADDR2: in  REG_ADDR;
        RDATA1: out WORD32;
        RDATA2: out WORD32
    );
end TR8A32_REGISTER_FILE;

architecture RTL of TR8A32_REGISTER_FILE is
    type REGISTER_ARRAY is array (0 to 31) of WORD32;
    signal registers : REGISTER_ARRAY := (others => (others => '0'));
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' then
                registers <= (others => (others => '0'));
            elsif WE = '1' and WADDR /= "00000" then
                registers(to_integer(unsigned(WADDR))) <= WDATA;
            end if;
        end if;
    end process;

    RDATA1 <= (others => '0') when RADDR1 = "00000" else
              registers(to_integer(unsigned(RADDR1)));
    RDATA2 <= (others => '0') when RADDR2 = "00000" else
              registers(to_integer(unsigned(RADDR2)));
end RTL;
