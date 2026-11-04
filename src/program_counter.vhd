library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PROGRAM_COUNTER is
    Port (
        CLK       : in  STD_LOGIC;
        RESET     : in  STD_LOGIC;
        ENABLE    : in  STD_LOGIC;
        JUMP      : in  STD_LOGIC;
        JUMP_ADDR : in  STD_LOGIC_VECTOR(7 downto 0);
        PC_OUT    : out STD_LOGIC_VECTOR(7 downto 0)
    );
end PROGRAM_COUNTER;

architecture RTL of PROGRAM_COUNTER is
    signal PC : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' then
                PC <= (others => '0');
            elsif ENABLE = '1' then
                if JUMP = '1' then
                    PC <= JUMP_ADDR;
                else
                    PC <= std_logic_vector(unsigned(PC) + 1);
                end if;
            end if;
        end if;
    end process;

    PC_OUT <= PC;
end RTL;
