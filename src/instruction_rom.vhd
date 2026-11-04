library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.TR8_ISA_PKG.ALL;

entity INSTRUCTION_ROM is
    generic (
        PROGRAM : ROM_ARRAY := SAMPLE_PROGRAM
    );
    Port (
        ADDR : in  STD_LOGIC_VECTOR(7 downto 0);
        DATA : out STD_LOGIC_VECTOR(15 downto 0)
    );
end INSTRUCTION_ROM;

architecture RTL of INSTRUCTION_ROM is
begin
    DATA <= PROGRAM(to_integer(unsigned(ADDR)));
end RTL;
