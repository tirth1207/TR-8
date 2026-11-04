library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.ALL;
use work.TR8A32_ISA_PKG.ALL;

entity TR8A32_MEMORY_TB is
end TR8A32_MEMORY_TB;

architecture SIM of TR8A32_MEMORY_TB is
    signal clk : STD_LOGIC := '0';
    signal reset, valid, write, ready, error : STD_LOGIC := '0';
    signal instr_addr, instr_data, data_addr, data_wdata, data_rdata : WORD32 :=
        (others => '0');
    signal timer_rdata : WORD32 := (others => '0');
    signal timer_ready, timer_error, timer_valid, timer_write : STD_LOGIC := '0';
begin
    clk <= not clk after 5 ns;
    dut: entity work.TR8A32_MEMORY
        port map (
            CLK => clk, RESET => reset, INSTR_ADDR => instr_addr,
            INSTR_DATA => instr_data, DATA_VALID => valid, DATA_WRITE => write,
            DATA_ADDR => data_addr, DATA_WDATA => data_wdata,
            DATA_RDATA => data_rdata, DATA_READY => ready, DATA_ERROR => error,
            TIMER_RDATA => timer_rdata, TIMER_READY => timer_ready,
            TIMER_ERROR => timer_error, TIMER_VALID => timer_valid,
            TIMER_WRITE => timer_write
        );

    process
    begin
        reset <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        reset <= '0';

        data_addr <= x"00000010";
        data_wdata <= x"12345678";
        valid <= '1';
        write <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        valid <= '0';
        write <= '0';
        wait for 1 ns;
        assert ready = '0' and data_rdata = x"12345678"
            report "memory write/read failed" severity failure;

        data_addr <= x"00000010";
        valid <= '1';
        wait for 1 ns;
        assert ready = '1' and error = '0' and data_rdata = x"12345678"
            report "memory read transaction failed" severity failure;
        valid <= '0';

        data_addr <= x"00001000";
        valid <= '1';
        wait for 1 ns;
        assert ready = '1' and error = '1'
            report "unmapped address error failed" severity failure;
        valid <= '0';

        reset <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        reset <= '0';
        data_addr <= x"00000010";
        wait for 1 ns;
        assert data_rdata = x"00000000"
            report "memory reset failed" severity failure;

        report "TR8-A32 MEMORY TESTS PASSED";
        stop;
        wait;
    end process;
end SIM;
