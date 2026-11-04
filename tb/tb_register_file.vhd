
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.ENV.ALL;

entity TB_REGISTER_FILE is
end TB_REGISTER_FILE;

architecture SIM of TB_REGISTER_FILE is

    signal CLK : STD_LOGIC := '0';
    signal RESET : STD_LOGIC := '0';

    signal WE : STD_LOGIC := '0';
    signal WADDR : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal WDATA : STD_LOGIC_VECTOR(7 downto 0) := x"00";

    signal RADDR1 : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal RADDR2 : STD_LOGIC_VECTOR(1 downto 0) := "00";

    signal RDATA1 : STD_LOGIC_VECTOR(7 downto 0);
    signal RDATA2 : STD_LOGIC_VECTOR(7 downto 0);

begin

    -- Clock: 10 ns period
    CLK <= not CLK after 5 ns;

    DUT: entity work.REGISTER_FILE
        port map (
            CLK => CLK,
            RESET => RESET,
            WE => WE,
            WADDR => WADDR,
            WDATA => WDATA,
            RADDR1 => RADDR1,
            RADDR2 => RADDR2,
            RDATA1 => RDATA1,
            RDATA2 => RDATA2
        );

    process
    begin

        -- Reset registers
        RESET <= '1';
        wait for 12 ns;
        RESET <= '0';

        -- Write 5 into R0
        WE <= '1';
        WADDR <= "00";
        WDATA <= x"05";
        wait for 10 ns;

        -- Write 3 into R1
        WADDR <= "01";
        WDATA <= x"03";
        wait for 10 ns;

        -- Read R0 and R1 simultaneously
        WE <= '0';
        RADDR1 <= "00";
        RADDR2 <= "01";
        wait for 1 ns;

        assert RDATA1 = x"05"
            report "R0 read failed" severity failure;

        assert RDATA2 = x"03"
            report "R1 read failed" severity failure;

        -- Write 8 into R2
        WE <= '1';
        WADDR <= "10";
        WDATA <= x"08";
        wait for 10 ns;

        -- Read R2
        WE <= '0';
        RADDR1 <= "10";
        wait for 1 ns;

        assert RDATA1 = x"08"
            report "R2 read failed" severity failure;

        -- Reset all registers again
        RESET <= '1';
        wait for 10 ns;
        RESET <= '0';

        RADDR1 <= "00";
        RADDR2 <= "01";
        wait for 1 ns;

        assert RDATA1 = x"00"
            report "R0 reset failed" severity failure;

        assert RDATA2 = x"00"
            report "R1 reset failed" severity failure;

        report "ALL REGISTER FILE TESTS PASSED!";
        stop;
        wait;

    end process;

end SIM;
