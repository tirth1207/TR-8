
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.ENV.ALL;

entity TB_AND_GATE is
end TB_AND_GATE;

architecture SIM of TB_AND_GATE is

    signal A : STD_LOGIC := '0';
    signal B : STD_LOGIC := '0';
    signal Y : STD_LOGIC;

begin

    DUT: entity work.AND_GATE
        port map (
            A => A,
            B => B,
            Y => Y
        );

    process
    begin

        -- Test 1: 0 AND 0 = 0
        A <= '0';
        B <= '0';
        wait for 10 ns;

        assert Y = '0'
            report "Test 1 failed"
            severity failure;

        -- Test 2: 0 AND 1 = 0
        A <= '0';
        B <= '1';
        wait for 10 ns;

        assert Y = '0'
            report "Test 2 failed"
            severity failure;

        -- Test 3: 1 AND 0 = 0
        A <= '1';
        B <= '0';
        wait for 10 ns;

        assert Y = '0'
            report "Test 3 failed"
            severity failure;

        -- Test 4: 1 AND 1 = 1
        A <= '1';
        B <= '1';
        wait for 10 ns;

        assert Y = '1'
            report "Test 4 failed"
            severity failure;

        report "ALL AND GATE TESTS PASSED!";

        stop;
        wait;

    end process;

end SIM;
