library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.ENV.ALL;
use work.TR8A32_ISA_PKG.ALL;

entity TR8A32_ALU_TB is
end TR8A32_ALU_TB;

architecture SIM of TR8A32_ALU_TB is
    signal a, b, result : WORD32 := (others => '0');
    signal op : STD_LOGIC_VECTOR(3 downto 0) := ALU_ADD;
    signal zero, negative, carry, overflow : STD_LOGIC;
begin
    dut: entity work.TR8A32_ALU
        port map (a, b, op, result, zero, negative, carry, overflow);

    process
    begin
        a <= x"00000005"; b <= x"00000003"; op <= ALU_ADD;
        wait for 1 ns;
        assert result = x"00000008" and carry = '0' and overflow = '0'
            report "32-bit ADD failed" severity failure;
        a <= x"FFFFFFFF"; b <= x"00000001"; op <= ALU_ADD;
        wait for 1 ns;
        assert result = x"00000000" and carry = '1' and zero = '1'
            report "32-bit unsigned carry failed" severity failure;
        a <= x"7FFFFFFF"; b <= x"00000001"; op <= ALU_ADD;
        wait for 1 ns;
        assert result = x"80000000" and overflow = '1' and negative = '1'
            report "32-bit signed overflow failed" severity failure;
        a <= x"00000000"; b <= x"00000001"; op <= ALU_SUB;
        wait for 1 ns;
        assert result = x"FFFFFFFF" and negative = '1' and carry = '0'
            report "32-bit subtraction failed" severity failure;
        a <= x"FFFFFFFF"; b <= x"00000001"; op <= ALU_SRA;
        wait for 1 ns;
        assert result = x"FFFFFFFF" report "SRA failed" severity failure;
        a <= x"00000001"; b <= x"0000001F"; op <= ALU_SLL;
        wait for 1 ns;
        assert result = x"80000000" report "SLL failed" severity failure;
        a <= x"FFFFFFFF"; b <= x"00000001"; op <= ALU_SLT;
        wait for 1 ns;
        assert result = x"00000001" report "signed SLT failed" severity failure;
        a <= x"00000001"; b <= x"FFFFFFFF"; op <= ALU_SLTU;
        wait for 1 ns;
        assert result = x"00000001" report "unsigned SLTU failed" severity failure;
        report "TR8-A32 ALU TESTS PASSED";
        stop;
        wait;
    end process;
end SIM;
