
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port (
        A       : in  STD_LOGIC_VECTOR(7 downto 0);
        B       : in  STD_LOGIC_VECTOR(7 downto 0);
        ALU_SEL : in  STD_LOGIC_VECTOR(2 downto 0);

        RESULT  : out STD_LOGIC_VECTOR(7 downto 0);
        ZERO    : out STD_LOGIC
    );
end ALU;

architecture RTL of ALU is
    signal TEMP : STD_LOGIC_VECTOR(7 downto 0);
begin

    process(A, B, ALU_SEL)
    begin
        case ALU_SEL is

            when "000" =>
                TEMP <= std_logic_vector(unsigned(A) + unsigned(B));

            when "001" =>
                TEMP <= std_logic_vector(unsigned(A) - unsigned(B));

            when "010" =>
                TEMP <= A AND B;

            when "011" =>
                TEMP <= A OR B;

            when "100" =>
                TEMP <= A XOR B;

            when "101" =>
                TEMP <= NOT A;

            when "110" =>
                TEMP <= A;

            when "111" =>
                TEMP <= B;

            when others =>
                TEMP <= (others => '0');

        end case;
    end process;

    RESULT <= TEMP;
    ZERO <= '1' when TEMP = x"00" else '0';

end RTL;
