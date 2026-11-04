library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity INSTRUCTION_ROM is
    Port (
        ADDR : in  STD_LOGIC_VECTOR(7 downto 0);
        DATA : out STD_LOGIC_VECTOR(15 downto 0)
    );
end INSTRUCTION_ROM;

architecture RTL of INSTRUCTION_ROM is
    type ROM_ARRAY is array (0 to 255) of STD_LOGIC_VECTOR(15 downto 0);
    constant ROM : ROM_ARRAY := (
        0 => x"1005",
        1 => x"1403",
        2 => x"2100",
        3 => x"8010",
        4 => x"B000",
        others => x"0000"
    );
begin
    DATA <= ROM(to_integer(unsigned(ADDR)));
end RTL;
