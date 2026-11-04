library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.ALL;
use work.TR8A32_ISA_PKG.ALL;

entity TR8A32_CPU_TB is
end TR8A32_CPU_TB;

architecture SIM of TR8A32_CPU_TB is
    type PROGRAM_TYPE is array (0 to 31) of WORD32;
    constant PROGRAM : PROGRAM_TYPE := (
        0 => OP_LUI & "00001" & "00000" & x"0001",
        1 => OP_ADDI & "00010" & "00000" & x"0005",
        2 => OP_ADDI & "00011" & "00000" & x"0003",
        3 => OP_ALU_REG & "00100" & "00010" & "00011" & ALU_ADD & "0000000",
        4 => OP_SW & "00100" & "00000" & "0000000000010000",
        5 => OP_LW & "00101" & "00000" & "0000000000010000",
        6 => OP_BEQ & "00100" & "00101" & "0000000000000010",
        7 => OP_ADDI & "00110" & "00000" & x"00EE",
        8 => OP_BNE & "00100" & "00101" & "0000000000000010",
        9 => OP_ADDI & "00110" & "00000" & x"00AA",
        10 => OP_HALT & "00000000000000000000000000",
        others => (others => '0')
    );
    type MEMORY_TYPE is array (0 to 255) of WORD32;
    signal memory : MEMORY_TYPE := (others => (others => '0'));
    signal clk : STD_LOGIC := '0';
    signal reset, valid, write, irq, halted : STD_LOGIC := '0';
    signal instr_addr, instr_data, data_addr, data_wdata, data_rdata, debug_pc :
        WORD32 := (others => '0');
    signal state : STD_LOGIC_VECTOR(3 downto 0);
    signal mepc, mcause : WORD32;
begin
    clk <= not clk after 5 ns;
    instr_data <= PROGRAM(to_integer(unsigned(instr_addr(6 downto 2))));
    data_rdata <= memory(to_integer(unsigned(data_addr(9 downto 2))));

    process(clk)
    begin
        if rising_edge(clk) and valid = '1' and write = '1' then
            memory(to_integer(unsigned(data_addr(9 downto 2)))) <= data_wdata;
        end if;
    end process;

    dut: entity work.TR8A32_CPU
        port map (
            CLK => clk, RESET => reset, INSTR_ADDR => instr_addr,
            INSTR_DATA => instr_data, DATA_VALID => valid, DATA_WRITE => write,
            DATA_ADDR => data_addr, DATA_WDATA => data_wdata,
            DATA_RDATA => data_rdata, DATA_READY => '1', IRQ => irq,
            HALTED => halted, DEBUG_PC => debug_pc, DEBUG_STATE => state,
            DEBUG_MEPC => mepc, DEBUG_MCAUSE => mcause
        );

    process
    begin
        reset <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        reset <= '0';
        for i in 1 to 60 loop
            wait until rising_edge(clk);
            wait for 1 ns;
        end loop;
        assert memory(4) = x"00000008"
            report "CPU store result failed" severity failure;
        assert halted = '1' and debug_pc = x"00000028"
            report "CPU halt or branch target failed" severity failure;
        report "TR8-A32 CPU TESTS PASSED";
        stop;
        wait;
    end process;
end SIM;
