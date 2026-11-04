library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.ALL;
use work.TR8A32_ISA_PKG.ALL;

entity TR8A32_MISALIGNED_TB is
end TR8A32_MISALIGNED_TB;

architecture SIM of TR8A32_MISALIGNED_TB is
    type PROGRAM_TYPE is array (0 to 255) of WORD32;
    constant PROGRAM : PROGRAM_TYPE := (
        0  => OP_LW & "00001" & "00000" & x"0001",
        64 => OP_HALT & "00000000000000000000000000",
        others => (others => '0')
    );
    signal clk : STD_LOGIC := '0';
    signal reset, valid, write, halted : STD_LOGIC := '0';
    signal instr_addr, instr_data, data_addr, data_wdata, debug_pc :
        WORD32 := (others => '0');
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
            DATA_RDATA => (others => '0'), DATA_READY => '1',
            DATA_ERROR => '0', IRQ => '0',
            HALTED => halted, DEBUG_PC => debug_pc,
            DEBUG_STATE => state, DEBUG_MEPC => mepc, DEBUG_MCAUSE => mcause
        );

    process
    begin
        reset <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        reset <= '0';
        for i in 1 to 20 loop
            wait until rising_edge(clk);
            wait for 1 ns;
        end loop;
        assert mepc = x"00000000"
            report "Misaligned load did not save the faulting PC" severity failure;
        assert mcause = x"00000004"
            report "Load-address-misaligned cause was not recorded" severity failure;
        assert halted = '1' and debug_pc = x"00000100"
            report "CPU did not execute the alignment-fault handler" severity failure;
        report "TR8-A32 MISALIGNED ACCESS TESTS PASSED";
        stop;
        wait;
    end process;
end SIM;
