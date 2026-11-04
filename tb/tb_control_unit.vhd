library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.TR8_ISA_PKG.ALL;
use STD.ENV.ALL;

entity TB_CONTROL_UNIT is
end TB_CONTROL_UNIT;

architecture SIM of TB_CONTROL_UNIT is
    signal opcode : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal rd, waddr : STD_LOGIC_VECTOR(1 downto 0);
    signal zero, reg_we, ram_we, jump, halt : STD_LOGIC := '0';
    signal alu_sel : STD_LOGIC_VECTOR(2 downto 0);
    signal wb_sel : STD_LOGIC_VECTOR(1 downto 0);
begin
    dut: entity work.CONTROL_UNIT
        port map (opcode, rd, zero, alu_sel, reg_we, waddr, wb_sel,
                  ram_we, jump, halt);
    process
    begin
        rd <= "10"; opcode <= OP_LDI; wait for 1 ns;
        assert reg_we = '1' and waddr = "10" and wb_sel = "01"
            report "LDI control failed" severity failure;
        opcode <= OP_STORE; wait for 1 ns;
        assert ram_we = '1' and reg_we = '0'
            report "STORE control failed" severity failure;
        opcode <= OP_JZ; zero <= '0'; wait for 1 ns;
        assert jump = '0' report "JZ false branch failed" severity failure;
        zero <= '1'; wait for 1 ns;
        assert jump = '1' report "JZ true branch failed" severity failure;
        opcode <= OP_HALT; wait for 1 ns;
        assert halt = '1' and jump = '0' and ram_we = '0'
            report "HALT control failed" severity failure;
        opcode <= "1111"; wait for 1 ns;
        assert reg_we = '0' and ram_we = '0' and halt = '0'
            report "Reserved opcode policy failed" severity failure;
        report "ALL CONTROL UNIT TESTS PASSED!";
        stop;
        wait;
    end process;
end SIM;
