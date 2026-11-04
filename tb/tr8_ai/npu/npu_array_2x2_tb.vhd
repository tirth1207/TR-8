library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.ENV.ALL;

entity NPU_ARRAY_2X2_TB is
end NPU_ARRAY_2X2_TB;

architecture SIM of NPU_ARRAY_2X2_TB is
    signal clk : STD_LOGIC := '0';
    signal reset, start, done, busy, error : STD_LOGIC := '0';
    signal a00, a01, a10, a11, b00, b01, b10, b11 :
        STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal bias0, bias1, c00, c01, c10, c11 :
        STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal relu, saturate : STD_LOGIC := '0';
    signal quant_shift : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
begin
    clk <= not clk after 5 ns;
    dut: entity work.NPU_ARRAY_2X2
        port map (clk, reset, start, a00, a01, a10, a11, b00, b01, b10, b11,
                  bias0, bias1, relu, saturate, quant_shift, done, busy, error,
                  c00, c01, c10, c11);

    process
    begin
        reset <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        reset <= '0';
        a00 <= x"01"; a01 <= x"02"; a10 <= x"03"; a11 <= x"04";
        b00 <= x"05"; b01 <= x"06"; b10 <= x"07"; b11 <= x"08";
        bias0 <= x"00000001"; bias1 <= x"00000002";
        start <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        start <= '0';
        assert busy = '1' report "NPU did not enter busy state" severity failure;
        wait until rising_edge(clk);
        wait for 1 ns;
        assert done = '1' and c00 = x"00000014" and
            c01 = x"00000018" and c10 = x"0000002C" and
            c11 = x"00000034" and error = '0'
            report "2x2 INT8 matrix multiplication failed" severity failure;
        wait until rising_edge(clk);
        wait for 1 ns;
        assert done = '0' report "NPU done was not cleared" severity failure;
        quant_shift <= "00001";
        bias0 <= x"00000000";
        relu <= '0';
        saturate <= '0';
        start <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        start <= '0';
        wait until rising_edge(clk);
        wait for 1 ns;
        assert c00 = x"00000009"
            report "NPU quantization shift failed" severity failure;
        wait until rising_edge(clk);
        wait for 1 ns;
        bias0 <= x"FFFFFF00";
        bias1 <= x"00000000";
        relu <= '1';
        saturate <= '1';
        start <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        start <= '0';
        wait until rising_edge(clk);
        wait for 1 ns;
        assert c00 = x"00000000"
            report "NPU ReLU activation failed" severity failure;
        wait until rising_edge(clk);
        wait for 1 ns;
        bias0 <= x"7FFFFFFF";
        quant_shift <= "00000";
        relu <= '0';
        start <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        start <= '0';
        wait until rising_edge(clk);
        wait for 1 ns;
        assert c00 = x"7FFFFFFF"
            report "NPU saturation failed" severity failure;
        report "NPU 2X2 ARRAY TESTS PASSED";
        stop;
        wait;
    end process;
end SIM;
