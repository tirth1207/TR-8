library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.ENV.ALL;

entity TB_DATA_RAM is
end TB_DATA_RAM;

architecture SIM of TB_DATA_RAM is
    signal clk : STD_LOGIC := '0';
    signal reset, we : STD_LOGIC := '0';
    signal addr, din, dout : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
begin
    clk <= not clk after 5 ns;
    dut: entity work.DATA_RAM port map (clk, reset, we, addr, din, dout);
    process
    begin
        reset <= '1'; wait until rising_edge(clk); wait for 1 ns;
        reset <= '0'; addr <= x"10"; we <= '1'; din <= x"AB";
        wait until rising_edge(clk); wait for 1 ns;
        we <= '0'; assert dout = x"AB" report "RAM write/read failed" severity failure;
        addr <= x"20"; din <= x"55"; we <= '1';
        wait until rising_edge(clk); wait for 1 ns;
        we <= '0'; assert dout = x"55" report "RAM second location failed" severity failure;
        reset <= '1'; wait until rising_edge(clk); wait for 1 ns;
        reset <= '0'; assert dout = x"00" report "RAM reset failed" severity failure;
        report "ALL DATA RAM TESTS PASSED!";
        stop;
        wait;
    end process;
end SIM;
