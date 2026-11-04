library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.ENV.ALL;

entity TB_TR8_CPU is
end TB_TR8_CPU;

architecture SIM of TB_TR8_CPU is
    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';
    signal pc, ram_addr, ram_data : STD_LOGIC_VECTOR(7 downto 0);
    signal instruction : STD_LOGIC_VECTOR(15 downto 0);
    signal r0, r1, r2, r3 : STD_LOGIC_VECTOR(7 downto 0);
    signal halted, zero, reg_we, ram_we : STD_LOGIC;
    signal opcode : STD_LOGIC_VECTOR(3 downto 0);
    signal rd, rs, reg_waddr : STD_LOGIC_VECTOR(1 downto 0);
    signal immediate : STD_LOGIC_VECTOR(7 downto 0);
    signal alu_a, alu_b, alu_result, reg_wdata : STD_LOGIC_VECTOR(7 downto 0);
    signal alu_sel : STD_LOGIC_VECTOR(2 downto 0);
begin
    clk <= not clk after 5 ns;
    dut: entity work.TR8_CPU
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
        reset <= '1'; wait until rising_edge(clk); wait for 1 ns;
        assert pc = x"00" and r0 = x"00" and zero = '0'
            report "CPU reset failed" severity failure;
        reset <= '0';
        for i in 1 to 5 loop
            wait until rising_edge(clk);
            wait for 1 ns;
            if i = 3 then
                assert ram_addr = x"10" and ram_we = '1' and alu_a = x"08"
                    report "CPU store controls failed" severity failure;
            end if;
        end loop;
        assert r0 = x"08" report "CPU arithmetic result failed" severity failure;
        assert r1 = x"03" report "CPU R1 result failed" severity failure;
        assert halted = '1' and pc = x"04" and zero = '0'
            report "CPU HALT state failed" severity failure;
        wait until rising_edge(clk); wait for 1 ns;
        assert pc = x"04" and r0 = x"08"
            report "CPU halted state changed" severity failure;
        reset <= '1'; wait until rising_edge(clk); wait for 1 ns;
        assert halted = '0' and pc = x"00" and r0 = x"00"
            report "CPU restart reset failed" severity failure;
        report "ALL TR-8 CPU TESTS PASSED!";
        stop;
        wait;
    end process;
end SIM;
