library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DATA_RAM is
    Port (
        CLK   : in  STD_LOGIC;
        RESET : in  STD_LOGIC;
        WE    : in  STD_LOGIC;
        ADDR  : in  STD_LOGIC_VECTOR(7 downto 0);
        DIN   : in  STD_LOGIC_VECTOR(7 downto 0);
        DOUT  : out STD_LOGIC_VECTOR(7 downto 0)
    );
end DATA_RAM;

architecture RTL of DATA_RAM is
    type RAM_ARRAY is array (0 to 255) of STD_LOGIC_VECTOR(7 downto 0);
    signal RAM : RAM_ARRAY := (others => (others => '0'));
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' then
                RAM <= (others => (others => '0'));
            elsif WE = '1' then
                RAM(to_integer(unsigned(ADDR))) <= DIN;
            end if;
        end if;
    end process;

    DOUT <= RAM(to_integer(unsigned(ADDR)));
end RTL;
