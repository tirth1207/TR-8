library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.ENV.ALL;

entity TB_PROGRAM_COUNTER is
end TB_PROGRAM_COUNTER;

architecture SIM of TB_PROGRAM_COUNTER is
    signal clk : STD_LOGIC := '0';
    signal reset, enable, jump : STD_LOGIC := '0';
    signal jump_addr, pc : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
begin
    clk <= not clk after 5 ns;
    dut: entity work.PROGRAM_COUNTER
        port map (clk, reset, enable, jump, jump_addr, pc);

    process
    begin
        reset <= '1'; wait until rising_edge(clk); wait for 1 ns;
        assert pc = x"00" report "PC reset failed" severity failure;
        reset <= '0'; enable <= '1'; wait until rising_edge(clk); wait for 1 ns;
        assert pc = x"01" report "PC increment failed" severity failure;
        jump <= '1'; jump_addr <= x"42"; wait until rising_edge(clk); wait for 1 ns;
        assert pc = x"42" report "PC jump failed" severity failure;
        jump <= '0'; enable <= '0'; wait until rising_edge(clk); wait for 1 ns;
        assert pc = x"42" report "PC hold failed" severity failure;
        enable <= '1'; jump_addr <= x"FF"; jump <= '1';
        wait until rising_edge(clk); wait for 1 ns;
        jump <= '0'; wait until rising_edge(clk); wait for 1 ns;
        assert pc = x"00" report "PC overflow failed" severity failure;
        report "ALL PROGRAM COUNTER TESTS PASSED!";
        stop;
        wait;
    end process;
end SIM;
