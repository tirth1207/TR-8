library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.ENV.ALL;
use work.TR8A32_ISA_PKG.ALL;

entity TR8A32_CSR_TB is
end TR8A32_CSR_TB;

architecture SIM of TR8A32_CSR_TB is
    signal clk : STD_LOGIC := '0';
    signal reset, irq, trap_taken, eret : STD_LOGIC := '0';
    signal mtvec, mepc, mcause : WORD32;
begin
    clk <= not clk after 5 ns;
    dut: entity work.TR8A32_CSR
        port map (clk, reset, irq, trap_taken, x"00000020", x"00000001",
                  eret, mtvec, mepc, mcause);

    process
    begin
        reset <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        assert mtvec = x"00000100" and mepc = x"00000000"
            report "CSR reset failed" severity failure;
        reset <= '0'; trap_taken <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        trap_taken <= '0';
        assert mepc = x"00000020" and mcause = x"00000001"
            report "CSR trap capture failed" severity failure;
        eret <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        assert mepc = x"00000020" and mcause = x"00000000"
            report "CSR ERET state failed" severity failure;
        report "TR8-A32 CSR TESTS PASSED";
        stop;
        wait;
    end process;
end SIM;
