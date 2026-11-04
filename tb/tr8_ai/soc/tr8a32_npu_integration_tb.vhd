library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.ALL;
use work.TR8A32_ISA_PKG.ALL;

entity TR8A32_NPU_INTEGRATION_TB is
end TR8A32_NPU_INTEGRATION_TB;

architecture SIM of TR8A32_NPU_INTEGRATION_TB is
    function imm(opcode : STD_LOGIC_VECTOR(5 downto 0);
                 rd : natural; rs1 : natural; value : natural)
                 return WORD32 is
    begin
        return opcode & STD_LOGIC_VECTOR(to_unsigned(rd, 5)) &
               STD_LOGIC_VECTOR(to_unsigned(rs1, 5)) &
               STD_LOGIC_VECTOR(to_unsigned(value, 16));
    end function;

    function store(source : natural; address : natural) return WORD32 is
    begin
        return OP_SW & STD_LOGIC_VECTOR(to_unsigned(source, 5)) &
               "00000" & STD_LOGIC_VECTOR(to_unsigned(address, 16));
    end function;

    function load(rd : natural; address : natural) return WORD32 is
    begin
        return OP_LW & STD_LOGIC_VECTOR(to_unsigned(rd, 5)) &
               "00000" & STD_LOGIC_VECTOR(to_unsigned(address, 16));
    end function;

    constant PROGRAM : PROGRAM_ARRAY := (
        0  => imm(OP_ADDI, 1, 0, 1),
        1  => imm(OP_ADDI, 2, 0, 2),
        2  => imm(OP_ADDI, 3, 0, 3),
        3  => imm(OP_ADDI, 4, 0, 4),
        4  => imm(OP_ADDI, 5, 0, 5),
        5  => imm(OP_ADDI, 6, 0, 6),
        6  => imm(OP_ADDI, 7, 0, 7),
        7  => imm(OP_ADDI, 8, 0, 8),
        8  => imm(OP_ADDI, 9, 0, 1),
        9  => imm(OP_ADDI, 10, 0, 2),
        10 => store(1, 16#180#),
        11 => store(2, 16#184#),
        12 => store(3, 16#188#),
        13 => store(4, 16#18C#),
        14 => store(5, 16#190#),
        15 => store(6, 16#194#),
        16 => store(7, 16#198#),
        17 => store(8, 16#19C#),
        18 => store(9, 16#1A0#),
        19 => store(10, 16#1A4#),
        20 => store(1, 16#100#),
        21 => imm(OP_ADDI, 11, 0, 0),
        22 => imm(OP_ADDI, 11, 11, 0),
        23 => load(12, 16#110#),
        24 => OP_HALT & "00000000000000000000000000",
        64 => store(2, 16#100#),
        65 => OP_ERET & "00000000000000000000000000",
        others => (others => '0')
    );
    signal clk : STD_LOGIC := '0';
    signal reset, halted : STD_LOGIC := '0';
    signal pc, mepc, mcause, npu_c00, npu_status : WORD32;
begin
    clk <= not clk after 5 ns;
    dut: entity work.TR8A32_SOC
        generic map (PROGRAM => PROGRAM)
        port map (clk, reset, halted, pc, mepc, mcause, npu_c00, npu_status);

    process
    begin
        reset <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        reset <= '0';
        for i in 1 to 180 loop
            wait until rising_edge(clk);
            wait for 1 ns;
        end loop;
        assert halted = '1' report "CPU did not halt after NPU program" severity failure;
        assert npu_c00 = x"00000014"
            report "CPU-driven NPU output readback failed" severity failure;
        report "TR8-A32 CPU-NPU INTEGRATION TESTS PASSED";
        stop;
        wait;
    end process;
end SIM;
