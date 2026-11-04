library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.ENV.ALL;

entity NPU_INT8_MAC_TB is
end NPU_INT8_MAC_TB;

architecture SIM of NPU_INT8_MAC_TB is
    signal clk : STD_LOGIC := '0';
    signal reset, clear, enable : STD_LOGIC := '0';
    signal a, b : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal acc : STD_LOGIC_VECTOR(31 downto 0);
begin
    clk <= not clk after 5 ns;
    dut: entity work.NPU_INT8_MAC
        port map (clk, reset, clear, enable, a, b, acc);

    process
    begin
        reset <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        reset <= '0';
        a <= x"03"; b <= x"04"; enable <= '1';
        wait until rising_edge(clk);
        a <= x"FE"; b <= x"02";
        wait until rising_edge(clk);
        wait for 1 ns;
        assert acc = x"00000008"
            report "signed INT8 MAC failed" severity failure;
        clear <= '1'; enable <= '0';
        wait until rising_edge(clk);
        wait for 1 ns;
        assert acc = x"00000000" report "MAC clear failed" severity failure;
        report "NPU INT8 MAC TESTS PASSED";
        stop;
        wait;
    end process;
end SIM;
