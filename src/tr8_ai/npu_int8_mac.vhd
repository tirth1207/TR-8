library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity NPU_INT8_MAC is
    Port (
        CLK       : in  STD_LOGIC;
        RESET     : in  STD_LOGIC;
        CLEAR     : in  STD_LOGIC;
        ENABLE    : in  STD_LOGIC;
        A         : in  STD_LOGIC_VECTOR(7 downto 0);
        B         : in  STD_LOGIC_VECTOR(7 downto 0);
        ACC       : out STD_LOGIC_VECTOR(31 downto 0)
    );
end NPU_INT8_MAC;

architecture RTL of NPU_INT8_MAC is
    signal accumulator : signed(31 downto 0) := (others => '0');
begin
    process(CLK)
        variable product : signed(15 downto 0);
        variable next_accumulator : signed(31 downto 0);
    begin
        if rising_edge(CLK) then
            if RESET = '1' or CLEAR = '1' then
                accumulator <= (others => '0');
            elsif ENABLE = '1' then
                product := signed(A) * signed(B);
                next_accumulator := accumulator + resize(product, 32);
                accumulator <= next_accumulator;
            end if;
        end if;
    end process;

    ACC <= std_logic_vector(accumulator);
end RTL;
