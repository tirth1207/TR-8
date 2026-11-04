
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity REGISTER_FILE is
    Port (
        CLK   : in STD_LOGIC;
        RESET : in STD_LOGIC;

        WE    : in STD_LOGIC;
        WADDR : in STD_LOGIC_VECTOR(1 downto 0);
        WDATA : in STD_LOGIC_VECTOR(7 downto 0);

        RADDR1 : in STD_LOGIC_VECTOR(1 downto 0);
        RADDR2 : in STD_LOGIC_VECTOR(1 downto 0);

        RDATA1 : out STD_LOGIC_VECTOR(7 downto 0);
        RDATA2 : out STD_LOGIC_VECTOR(7 downto 0);

        DEBUG_R0 : out STD_LOGIC_VECTOR(7 downto 0);
        DEBUG_R1 : out STD_LOGIC_VECTOR(7 downto 0);
        DEBUG_R2 : out STD_LOGIC_VECTOR(7 downto 0);
        DEBUG_R3 : out STD_LOGIC_VECTOR(7 downto 0)
    );
end REGISTER_FILE;

architecture RTL of REGISTER_FILE is

    type REG_ARRAY is array (0 to 3) of
        STD_LOGIC_VECTOR(7 downto 0);

    signal REGISTERS : REG_ARRAY := (others => (others => '0'));

begin

    -- Synchronous write port
    process(CLK)
    begin
        if rising_edge(CLK) then

            if RESET = '1' then
                REGISTERS <= (others => (others => '0'));

            elsif WE = '1' then
                REGISTERS(to_integer(unsigned(WADDR))) <= WDATA;

            end if;

        end if;
    end process;

    -- Asynchronous read ports
    RDATA1 <= REGISTERS(to_integer(unsigned(RADDR1)));
    RDATA2 <= REGISTERS(to_integer(unsigned(RADDR2)));
    DEBUG_R0 <= REGISTERS(0);
    DEBUG_R1 <= REGISTERS(1);
    DEBUG_R2 <= REGISTERS(2);
    DEBUG_R3 <= REGISTERS(3);

end RTL;
