library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.TR8A32_ISA_PKG.ALL;

entity TR8A32_TIMER is
    Port (
        CLK       : in  STD_LOGIC;
        RESET     : in  STD_LOGIC;
        VALID     : in  STD_LOGIC;
        WRITE     : in  STD_LOGIC;
        ADDR      : in  WORD32;
        WDATA     : in  WORD32;
        RDATA     : out WORD32;
        READY     : out STD_LOGIC;
        ERROR     : out STD_LOGIC;
        IRQ       : out STD_LOGIC
    );
end TR8A32_TIMER;

architecture RTL of TR8A32_TIMER is
    signal counter : unsigned(31 downto 0) := (others => '0');
    signal compare_value : unsigned(31 downto 0) := (others => '0');
    signal enabled, pending : STD_LOGIC := '0';
    signal offset : STD_LOGIC_VECTOR(3 downto 0);
    signal selected : STD_LOGIC;
begin
    selected <= '1' when ADDR(31 downto 4) = x"0000040" else '0';
    offset <= ADDR(3 downto 0);
    READY <= VALID and selected;
    ERROR <= VALID and not selected;
    IRQ <= pending;

    with offset select
        RDATA <= std_logic_vector(counter)       when x"0",
                 std_logic_vector(compare_value)  when x"4",
                 x"00000001" when x"8",
                 (others => '0') when others;

    process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' then
                counter <= (others => '0');
                compare_value <= (others => '0');
                enabled <= '0';
                pending <= '0';
            else
                counter <= counter + 1;
                if enabled = '1' and compare_value /= 0 and
                   counter + 1 >= compare_value then
                    pending <= '1';
                end if;
                if VALID = '1' and WRITE = '1' and selected = '1' then
                    case offset is
                        when x"0" =>
                            counter <= unsigned(WDATA);
                        when x"4" =>
                            compare_value <= unsigned(WDATA);
                        when x"8" =>
                            enabled <= WDATA(0);
                        when x"C" =>
                            pending <= '0';
                        when others =>
                            null;
                    end case;
                end if;
            end if;
        end if;
    end process;
end RTL;
