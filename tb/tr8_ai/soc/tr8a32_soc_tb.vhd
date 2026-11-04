library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.ENV.ALL;

entity TR8A32_SOC_TB is
end TR8A32_SOC_TB;

architecture SIM of TR8A32_SOC_TB is
    signal clk : STD_LOGIC := '0';
    signal reset, halted : STD_LOGIC := '0';
    signal pc : STD_LOGIC_VECTOR(31 downto 0);
    signal mepc, mcause : STD_LOGIC_VECTOR(31 downto 0);
    signal npu_c00, npu_status : STD_LOGIC_VECTOR(31 downto 0);
begin
    clk <= not clk after 5 ns;
    dut: entity work.TR8A32_SOC
        port map (clk, reset, halted, pc, mepc, mcause, npu_c00, npu_status);

    process
    begin
        reset <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        reset <= '0';
        for i in 1 to 30 loop
            wait until rising_edge(clk);
            wait for 1 ns;
        end loop;
        assert halted = '0' report "empty SoC did not remain runnable" severity failure;
        assert pc /= x"00000000" report "SoC CPU did not fetch instructions" severity failure;
        report "TR8-A32 SOC TESTS PASSED";
        stop;
        wait;
    end process;
end SIM;
