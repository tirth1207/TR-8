library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.ALL;
use work.TR8A32_ISA_PKG.ALL;

entity TR8A32_INTERRUPT_TB is
end TR8A32_INTERRUPT_TB;

architecture SIM of TR8A32_INTERRUPT_TB is
    type PROGRAM_TYPE is array (0 to 255) of WORD32;
    constant PROGRAM : PROGRAM_TYPE := (
        0   => OP_HALT & "00000000000000000000000000",
        64  => OP_ERET & "00000000000000000000000000",
        others => (others => '0')
    );
    signal clk : STD_LOGIC := '0';
    signal reset, irq, halted : STD_LOGIC := '0';
    signal instr_addr, instr_data, data_addr, data_wdata, data_rdata, debug_pc :
        WORD32 := (others => '0');
    signal valid, write : STD_LOGIC;
    signal state : STD_LOGIC_VECTOR(3 downto 0);
    signal mepc, mcause : WORD32;
begin
    clk <= not clk after 5 ns;
    instr_data <= PROGRAM(to_integer(unsigned(instr_addr(9 downto 2))));

    dut: entity work.TR8A32_CPU
        port map (
            CLK => clk, RESET => reset, INSTR_ADDR => instr_addr,
            INSTR_DATA => instr_data, DATA_VALID => valid, DATA_WRITE => write,
            DATA_ADDR => data_addr, DATA_WDATA => data_wdata,
            DATA_RDATA => data_rdata, DATA_READY => '1', DATA_ERROR => '0', IRQ => irq,
            HALTED => halted, DEBUG_PC => debug_pc,
            DEBUG_STATE => state, DEBUG_MEPC => mepc, DEBUG_MCAUSE => mcause
        );

    process
    begin
        reset <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        reset <= '0';
        irq <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        irq <= '0';
        report "trap pc=" & integer'image(to_integer(unsigned(debug_pc))) &
            " mepc=" & integer'image(to_integer(unsigned(mepc))) &
            " cause=" & integer'image(to_integer(unsigned(mcause)));
        assert debug_pc = x"00000100" and mepc = x"00000000" and
            mcause = x"00000001"
            report "interrupt trap entry failed" severity failure;
        wait until rising_edge(clk);
        wait for 1 ns;
        wait until rising_edge(clk);
        wait for 1 ns;
        wait until rising_edge(clk);
        wait for 1 ns;
        assert debug_pc = x"00000000"
            report "ERET did not return to saved PC" severity failure;
        wait until rising_edge(clk);
        wait for 1 ns;
        wait until rising_edge(clk);
        wait for 1 ns;
        wait until rising_edge(clk);
        wait for 1 ns;
        assert halted = '1'
            report "post-interrupt program did not resume" severity failure;
        report "TR8-A32 INTERRUPT TESTS PASSED";
        stop;
        wait;
    end process;
end SIM;
