library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity NPU_ARRAY_2X2 is
    Port (
        CLK       : in  STD_LOGIC;
        RESET     : in  STD_LOGIC;
        START     : in  STD_LOGIC;
        A00       : in  STD_LOGIC_VECTOR(7 downto 0);
        A01       : in  STD_LOGIC_VECTOR(7 downto 0);
        A10       : in  STD_LOGIC_VECTOR(7 downto 0);
        A11       : in  STD_LOGIC_VECTOR(7 downto 0);
        B00       : in  STD_LOGIC_VECTOR(7 downto 0);
        B01       : in  STD_LOGIC_VECTOR(7 downto 0);
        B10       : in  STD_LOGIC_VECTOR(7 downto 0);
        B11       : in  STD_LOGIC_VECTOR(7 downto 0);
        BIAS0     : in  STD_LOGIC_VECTOR(31 downto 0);
        BIAS1     : in  STD_LOGIC_VECTOR(31 downto 0);
        RELU      : in  STD_LOGIC;
        SATURATE  : in  STD_LOGIC;
        QUANT_SHIFT : in STD_LOGIC_VECTOR(4 downto 0);
        DONE      : out STD_LOGIC;
        BUSY      : out STD_LOGIC;
        ERROR     : out STD_LOGIC;
        C00       : out STD_LOGIC_VECTOR(31 downto 0);
        C01       : out STD_LOGIC_VECTOR(31 downto 0);
        C10       : out STD_LOGIC_VECTOR(31 downto 0);
        C11       : out STD_LOGIC_VECTOR(31 downto 0)
    );
end NPU_ARRAY_2X2;

architecture RTL of NPU_ARRAY_2X2 is
    type STATE_TYPE is (IDLE, CALCULATE, COMPLETE);
    signal state : STATE_TYPE := IDLE;
    signal result00, result01, result10, result11 : signed(31 downto 0) :=
        (others => '0');
    signal a00_reg, a01_reg, a10_reg, a11_reg : signed(7 downto 0);
    signal b00_reg, b01_reg, b10_reg, b11_reg : signed(7 downto 0);
    signal bias0_reg, bias1_reg : signed(31 downto 0);
begin
    process(CLK)
        variable wide00, wide01, wide10, wide11 : signed(33 downto 0);
        variable shifted : signed(33 downto 0);
        variable next00, next01, next10, next11 : signed(31 downto 0);
        variable saturated : signed(31 downto 0);
    begin
        if rising_edge(CLK) then
            if RESET = '1' then
                state <= IDLE;
                result00 <= (others => '0');
                result01 <= (others => '0');
                result10 <= (others => '0');
                result11 <= (others => '0');
            else
                case state is
                    when IDLE =>
                        if START = '1' then
                            a00_reg <= signed(A00);
                            a01_reg <= signed(A01);
                            a10_reg <= signed(A10);
                            a11_reg <= signed(A11);
                            b00_reg <= signed(B00);
                            b01_reg <= signed(B01);
                            b10_reg <= signed(B10);
                            b11_reg <= signed(B11);
                            bias0_reg <= signed(BIAS0);
                            bias1_reg <= signed(BIAS1);
                            state <= CALCULATE;
                        end if;
                    when CALCULATE =>
                        wide00 := resize(bias0_reg, 34) +
                            resize(a00_reg * b00_reg, 34) +
                            resize(a01_reg * b10_reg, 34);
                        wide01 := resize(bias1_reg, 34) +
                            resize(a00_reg * b01_reg, 34) +
                            resize(a01_reg * b11_reg, 34);
                        wide10 := resize(bias0_reg, 34) +
                            resize(a10_reg * b00_reg, 34) +
                            resize(a11_reg * b10_reg, 34);
                        wide11 := resize(bias1_reg, 34) +
                            resize(a10_reg * b01_reg, 34) +
                            resize(a11_reg * b11_reg, 34);

                        shifted := shift_right(wide00, to_integer(unsigned(QUANT_SHIFT)));
                        if SATURATE = '1' then
                            if shifted > to_signed(2147483647, 34) then
                                saturated := to_signed(2147483647, 32);
                            elsif shifted < to_signed(-2147483648, 34) then
                                saturated := to_signed(-2147483648, 32);
                            else
                                saturated := resize(shifted, 32);
                            end if;
                        else
                            saturated := resize(shifted, 32);
                        end if;
                        if RELU = '1' and saturated(31) = '1' then
                            next00 := (others => '0');
                        else
                            next00 := saturated;
                        end if;

                        shifted := shift_right(wide01, to_integer(unsigned(QUANT_SHIFT)));
                        if SATURATE = '1' then
                            if shifted > to_signed(2147483647, 34) then
                                saturated := to_signed(2147483647, 32);
                            elsif shifted < to_signed(-2147483648, 34) then
                                saturated := to_signed(-2147483648, 32);
                            else
                                saturated := resize(shifted, 32);
                            end if;
                        else
                            saturated := resize(shifted, 32);
                        end if;
                        if RELU = '1' and saturated(31) = '1' then
                            next01 := (others => '0');
                        else
                            next01 := saturated;
                        end if;

                        shifted := shift_right(wide10, to_integer(unsigned(QUANT_SHIFT)));
                        if SATURATE = '1' then
                            if shifted > to_signed(2147483647, 34) then
                                saturated := to_signed(2147483647, 32);
                            elsif shifted < to_signed(-2147483648, 34) then
                                saturated := to_signed(-2147483648, 32);
                            else
                                saturated := resize(shifted, 32);
                            end if;
                        else
                            saturated := resize(shifted, 32);
                        end if;
                        if RELU = '1' and saturated(31) = '1' then
                            next10 := (others => '0');
                        else
                            next10 := saturated;
                        end if;

                        shifted := shift_right(wide11, to_integer(unsigned(QUANT_SHIFT)));
                        if SATURATE = '1' then
                            if shifted > to_signed(2147483647, 34) then
                                saturated := to_signed(2147483647, 32);
                            elsif shifted < to_signed(-2147483648, 34) then
                                saturated := to_signed(-2147483648, 32);
                            else
                                saturated := resize(shifted, 32);
                            end if;
                        else
                            saturated := resize(shifted, 32);
                        end if;
                        if RELU = '1' and saturated(31) = '1' then
                            next11 := (others => '0');
                        else
                            next11 := saturated;
                        end if;
                        result00 <= next00;
                        result01 <= next01;
                        result10 <= next10;
                        result11 <= next11;
                        state <= COMPLETE;
                    when COMPLETE =>
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;

    BUSY <= '1' when state = CALCULATE else '0';
    DONE <= '1' when state = COMPLETE else '0';
    ERROR <= '1' when START = '1' and state /= IDLE else '0';
    C00 <= std_logic_vector(result00);
    C01 <= std_logic_vector(result01);
    C10 <= std_logic_vector(result10);
    C11 <= std_logic_vector(result11);
end RTL;
