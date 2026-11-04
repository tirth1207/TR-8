library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.ALL;
use work.TR8A32_ISA_PKG.ALL;

entity TR8A32_TIMER_TB is
end TR8A32_TIMER_TB;

architecture SIM of TR8A32_TIMER_TB is
    signal clk : STD_LOGIC := '0';
    signal reset, valid, write, ready, error, irq : STD_LOGIC := '0';
    signal addr, wdata, rdata : WORD32 := (others => '0');
begin
    clk <= not clk after 5 ns;
    dut: entity work.TR8A32_TIMER
        port map (clk, reset, valid, write, addr, wdata, rdata,
                  ready, error, irq);

    process
    begin
        reset <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        reset <= '0';

        addr <= x"00000004"; valid <= '1';
        wait for 1 ns;
        assert ready = '0' report "timer rejected unmapped offset incorrectly"
            severity failure;
        valid <= '0';

        addr <= x"00000404"; wdata <= x"00000003";
        valid <= '1'; write <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        valid <= '0'; write <= '0';

        addr <= x"00000408"; wdata <= x"00000001";
        valid <= '1'; write <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        valid <= '0'; write <= '0';
        for i in 1 to 4 loop
            wait until rising_edge(clk);
        end loop;
        wait for 1 ns;
        assert irq = '1' report "timer interrupt pending failed" severity failure;

        addr <= x"0000040C"; valid <= '1'; write <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        assert irq = '0' report "timer interrupt clear failed" severity failure;

        report "TR8-A32 TIMER TESTS PASSED";
        stop;
        wait;
    end process;
end SIM;
