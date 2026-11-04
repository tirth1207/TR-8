library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.ALL;

entity NPU_CONTROLLER_TB is
end NPU_CONTROLLER_TB;

architecture SIM of NPU_CONTROLLER_TB is
    signal clk : STD_LOGIC := '0';
    signal reset, valid, write, ready, error, irq : STD_LOGIC := '0';
    signal addr, wdata, rdata : STD_LOGIC_VECTOR(31 downto 0) :=
        (others => '0');
begin
    clk <= not clk after 5 ns;
    dut: entity work.NPU_CONTROLLER
        port map (clk, reset, valid, write, addr, wdata, rdata, ready, error,
                  irq);

    process
        procedure write_reg(
            constant offset : in STD_LOGIC_VECTOR(7 downto 0);
            constant value : in STD_LOGIC_VECTOR(31 downto 0)) is
        begin
            addr <= x"000001" & offset;
            wdata <= value;
            valid <= '1';
            write <= '1';
            wait until rising_edge(clk);
            wait for 1 ns;
            valid <= '0';
            write <= '0';
        end procedure;
        procedure read_reg(
            constant offset : in STD_LOGIC_VECTOR(7 downto 0)) is
        begin
            addr <= x"000001" & offset;
            valid <= '1';
            write <= '0';
            wait for 1 ns;
        end procedure;
    begin
        reset <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        reset <= '0';

        write_reg(x"80", x"00000001");
        write_reg(x"84", x"00000002");
        write_reg(x"88", x"00000003");
        write_reg(x"8C", x"00000004");
        write_reg(x"90", x"00000005");
        write_reg(x"94", x"00000006");
        write_reg(x"98", x"00000007");
        write_reg(x"9C", x"00000008");
        write_reg(x"A0", x"00000001");
        write_reg(x"A4", x"00000002");
        write_reg(x"00", x"00000001");

        read_reg(x"04");
        assert ready = '1' and error = '0' and rdata(0) = '1'
            report "NPU busy status failed" severity failure;
        valid <= '0';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait for 1 ns;

        read_reg(x"04");
        assert rdata(1) = '1' and rdata(0) = '0'
            report "NPU done status failed" severity failure;
        assert irq = '1' report "NPU completion IRQ failed" severity failure;
        valid <= '0';
        read_reg(x"10");
        assert rdata = x"00000014" report "NPU output C00 failed" severity failure;
        valid <= '0';
        read_reg(x"1C");
        assert rdata = x"00000034" report "NPU output C11 failed" severity failure;
        valid <= '0';

        write_reg(x"00", x"00000002");
        read_reg(x"04");
        assert rdata(1) = '0' report "NPU done clear failed" severity failure;
        assert irq = '0' report "NPU completion IRQ clear failed" severity failure;
        valid <= '0';
        write_reg(x"30", x"00000000");
        read_reg(x"30");
        assert rdata(0) = '0' report "NPU IRQ enable write failed"
            severity failure;
        valid <= '0';
        read_reg(x"34");
        assert unsigned(rdata) /= 0 report "NPU performance counter failed"
            severity failure;
        valid <= '0';
        read_reg(x"20");
        assert rdata = x"00020202" report "NPU default dimensions failed"
            severity failure;
        valid <= '0';
        write_reg(x"20", x"00020302");
        write_reg(x"00", x"00000001");
        read_reg(x"04");
        assert rdata(2) = '1' report "NPU invalid dimensions not rejected"
            severity failure;
        valid <= '0';
        write_reg(x"00", x"0000000C");
        read_reg(x"00");
        assert rdata(2) = '1' and rdata(3) = '1'
            report "NPU activation controls failed" severity failure;
        valid <= '0';
        write_reg(x"2C", x"00000001");
        read_reg(x"2C");
        assert rdata(4 downto 0) = "00001"
            report "NPU quantization shift write failed" severity failure;
        valid <= '0';
        report "NPU CONTROLLER TESTS PASSED";
        stop;
        wait;
    end process;
end SIM;
