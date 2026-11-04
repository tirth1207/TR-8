
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.ENV.ALL;

entity TB_ALU is
end TB_ALU;

architecture SIM of TB_ALU is

    signal A       : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal B       : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal ALU_SEL : STD_LOGIC_VECTOR(2 downto 0) := "000";

    signal RESULT  : STD_LOGIC_VECTOR(7 downto 0);
    signal ZERO    : STD_LOGIC;

begin

    DUT: entity work.ALU
        port map (
            A       => A,
            B       => B,
            ALU_SEL => ALU_SEL,
            RESULT  => RESULT,
            ZERO    => ZERO
        );

    process
    begin

        -- ADD: 5 + 3 = 8
        A <= x"05";
        B <= x"03";
        ALU_SEL <= "000";
        wait for 10 ns;
        assert RESULT = x"08" report "ADD failed" severity failure;

        -- SUB: 5 - 3 = 2
        ALU_SEL <= "001";
        wait for 10 ns;
        assert RESULT = x"02" report "SUB failed" severity failure;

        -- AND
        A <= x"0F";
        B <= x"03";
        ALU_SEL <= "010";
        wait for 10 ns;
        assert RESULT = x"03" report "AND failed" severity failure;

        -- OR
        ALU_SEL <= "011";
        wait for 10 ns;
        assert RESULT = x"0F" report "OR failed" severity failure;

        -- XOR
        ALU_SEL <= "100";
        wait for 10 ns;
        assert RESULT = x"0C" report "XOR failed" severity failure;

        -- NOT A
        ALU_SEL <= "101";
        wait for 10 ns;
        assert RESULT = x"F0" report "NOT failed" severity failure;

        -- PASS A
        ALU_SEL <= "110";
        wait for 10 ns;
        assert RESULT = x"0F" report "PASS A failed" severity failure;

        -- PASS B
        ALU_SEL <= "111";
        wait for 10 ns;
        assert RESULT = x"03" report "PASS B failed" severity failure;

        -- ZERO flag
        A <= x"05";
        B <= x"05";
        ALU_SEL <= "001";
        wait for 10 ns;
        assert RESULT = x"00" report "ZERO result failed" severity failure;
        assert ZERO = '1' report "ZERO flag failed" severity failure;

        report "ALL ALU TESTS PASSED!";
        stop;
        wait;

    end process;

end SIM;
