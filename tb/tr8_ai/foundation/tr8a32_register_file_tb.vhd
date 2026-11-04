library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.ENV.ALL;
use work.TR8A32_ISA_PKG.ALL;

entity TR8A32_REGISTER_FILE_TB is
end TR8A32_REGISTER_FILE_TB;

architecture SIM of TR8A32_REGISTER_FILE_TB is
    signal clk : STD_LOGIC := '0';
    signal reset, we : STD_LOGIC := '0';
    signal waddr, raddr1, raddr2 : REG_ADDR := (others => '0');
    signal wdata, rdata1, rdata2 : WORD32 := (others => '0');
begin
    clk <= not clk after 5 ns;
    dut: entity work.TR8A32_REGISTER_FILE
        port map (clk, reset, we, waddr, wdata, raddr1, raddr2, rdata1, rdata2);

    process
    begin
        reset <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        reset <= '0';
        we <= '1'; waddr <= "00001"; wdata <= x"12345678";
        wait until rising_edge(clk);
        wait for 1 ns;
        we <= '0'; raddr1 <= "00001";
        wait for 1 ns;
        assert rdata1 = x"12345678" report "register write/read failed" severity failure;
        raddr1 <= "00000"; raddr2 <= "00001";
        wait for 1 ns;
        assert rdata1 = x"00000000" and rdata2 = x"12345678"
            report "dual asynchronous reads failed" severity failure;
        we <= '1'; waddr <= "00000"; wdata <= x"FFFFFFFF";
        wait until rising_edge(clk);
        wait for 1 ns;
        assert rdata1 = x"00000000"
            report "x0 was not hardwired to zero" severity failure;
        reset <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        raddr2 <= "00001";
        wait for 1 ns;
        assert rdata2 = x"00000000" report "register reset failed" severity failure;
        report "TR8-A32 REGISTER FILE TESTS PASSED";
        stop;
        wait;
    end process;
end SIM;
