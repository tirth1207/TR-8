library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.ENV.ALL;
use work.TR8_ISA_PKG.ALL;

entity TB_TR8_CPU is
end TB_TR8_CPU;

architecture SIM of TB_TR8_CPU is
    constant TEST_PROGRAM : ROM_ARRAY := (
        0  => encode(OP_LDI,   "00", "00", x"05"),
        1  => encode(OP_LDI,   "01", "00", x"03"),
        2  => encode(OP_ADD,   "00", "01", x"00"),
        3  => encode(OP_STORE, "00", "00", x"10"),
        4  => encode(OP_LOAD,  "10", "00", x"10"),
        5  => encode(OP_SUB,   "10", "01", x"00"),
        6  => encode(OP_JZ,    "00", "00", x"09"),
        7  => encode(OP_LDI,   "11", "00", x"00"),
        8  => encode(OP_JZ,    "00", "00", x"0B"),
        9  => encode(OP_LDI,   "11", "00", x"EE"),
        10 => encode(OP_JMP,   "00", "00", x"0C"),
        11 => encode(OP_LDI,   "11", "00", x"AA"),
        12 => encode(OP_NOT,   "11", "00", x"00"),
        13 => encode(OP_AND,   "11", "00", x"00"),
        14 => encode(OP_JZ,    "00", "00", x"10"),
        15 => encode(OP_LDI,   "11", "00", x"FF"),
        16 => encode(OP_OR,    "11", "01", x"00"),
        17 => encode(OP_XOR,   "11", "01", x"00"),
        18 => encode(OP_LDI,   "11", "00", x"80"),
        19 => encode(OP_ADD,   "11", "11", x"00"),
        20 => encode(OP_LDI,   "11", "00", x"01"),
        21 => encode(OP_SUB,   "11", "01", x"00"),
        22 => encode(OP_STORE, "11", "00", x"20"),
        23 => encode(OP_LOAD,  "00", "00", x"20"),
        24 => encode(OP_NOP,   "00", "00", x"00"),
        25 => encode(OP_HALT,  "00", "00", x"00"),
        others => x"0000"
    );

    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';
    signal pc, ram_addr, ram_data : BYTE;
    signal instruction : WORD16;
    signal r0, r1, r2, r3 : BYTE;
    signal halted, zero, reg_we, ram_we : STD_LOGIC;
    signal opcode : STD_LOGIC_VECTOR(3 downto 0);
    signal rd, rs, reg_waddr : STD_LOGIC_VECTOR(1 downto 0);
    signal immediate : BYTE;
    signal alu_a, alu_b, alu_result, reg_wdata : BYTE;
    signal alu_sel : STD_LOGIC_VECTOR(2 downto 0);
begin
    clk <= not clk after 5 ns;

    dut: entity work.TR8_CPU
        generic map (PROGRAM => TEST_PROGRAM)
        port map (
            CLK => clk, RESET => reset, PC_OUT => pc,
            CURRENT_INSTRUCTION => instruction, HALTED => halted,
            DEBUG_R0 => r0, DEBUG_R1 => r1, DEBUG_R2 => r2, DEBUG_R3 => r3,
            DEBUG_ZERO => zero, DEBUG_RAM_ADDR => ram_addr,
            DEBUG_RAM_DATA => ram_data, DEBUG_OPCODE => opcode,
            DEBUG_RD => rd, DEBUG_RS => rs, DEBUG_IMMEDIATE => immediate,
            DEBUG_ALU_A => alu_a, DEBUG_ALU_B => alu_b,
            DEBUG_ALU_SEL => alu_sel, DEBUG_ALU_RESULT => alu_result,
            DEBUG_REG_WE => reg_we, DEBUG_REG_WADDR => reg_waddr,
            DEBUG_REG_WDATA => reg_wdata, DEBUG_RAM_WE => ram_we
        );

    process
    begin
        reset <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        assert pc = x"00" and r0 = x"00" and r1 = x"00" and
            r2 = x"00" and r3 = x"00" and zero = '0' and halted = '0'
            report "CPU reset failed" severity failure;

        reset <= '0';
        for i in 1 to 5 loop
            wait until rising_edge(clk);
            wait for 1 ns;
        end loop;

        assert r0 = x"08" and r1 = x"03" and r2 = x"08"
            report "STORE/LOAD data read-back failed" severity failure;

        for i in 6 to 25 loop
            wait until rising_edge(clk);
            wait for 1 ns;
        end loop;

        assert r0 = x"FE"
            report "STORE/LOAD read-back or final R0 result failed" severity failure;
        assert r1 = x"03" report "R1 result failed" severity failure;
        assert r2 = x"05" report "subtraction result failed" severity failure;
        assert r3 = x"FE"
            report "logic, overflow, or underflow result failed" severity failure;
        assert zero = '0' report "committed zero flag failed" severity failure;
        assert halted = '1' and pc = x"19"
            report "HALT state or PC failed" severity failure;

        wait until rising_edge(clk);
        wait for 1 ns;
        assert pc = x"19" and r0 = x"FE" and r3 = x"FE" and
            zero = '0' and halted = '1'
            report "HALT did not freeze architectural state" severity failure;

        reset <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        assert halted = '0' and pc = x"00" and r0 = x"00" and
            r1 = x"00" and r2 = x"00" and r3 = x"00" and zero = '0'
            report "reset did not restart CPU state" severity failure;

        report "ALL TR-8 CPU INTEGRATION TESTS PASSED!";
        stop;
        wait;
    end process;
end SIM;
