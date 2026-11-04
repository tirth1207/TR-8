library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.ENV.ALL;

entity TB_INSTRUCTION_ROM is
end TB_INSTRUCTION_ROM;

architecture SIM of TB_INSTRUCTION_ROM is
    signal addr : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal data : STD_LOGIC_VECTOR(15 downto 0);
begin
    dut: entity work.INSTRUCTION_ROM port map (addr, data);
    process
    begin
        addr <= x"00"; wait for 1 ns;
        assert data = x"1005" report "ROM address 0 failed" severity failure;
        addr <= x"04"; wait for 1 ns;
        assert data = x"B000" report "ROM HALT failed" severity failure;
        addr <= x"FF"; wait for 1 ns;
        assert data = x"0000" report "ROM NOP default failed" severity failure;
        report "ALL INSTRUCTION ROM TESTS PASSED!";
        stop;
        wait;
    end process;
end SIM;
