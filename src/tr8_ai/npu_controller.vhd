library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity NPU_CONTROLLER is
    Port (
        CLK   : in  STD_LOGIC;
        RESET : in  STD_LOGIC;
        VALID : in  STD_LOGIC;
        WRITE : in  STD_LOGIC;
        ADDR  : in  STD_LOGIC_VECTOR(31 downto 0);
        WDATA : in  STD_LOGIC_VECTOR(31 downto 0);
        RDATA : out STD_LOGIC_VECTOR(31 downto 0);
        READY : out STD_LOGIC;
        ERROR : out STD_LOGIC;
        IRQ   : out STD_LOGIC
    );
end NPU_CONTROLLER;

architecture RTL of NPU_CONTROLLER is
    type INT8_MEMORY is array (0 to 3) of STD_LOGIC_VECTOR(7 downto 0);
    type WORD_MEMORY is array (0 to 1) of STD_LOGIC_VECTOR(31 downto 0);
    signal start : STD_LOGIC;
    signal array_done, array_busy, array_error : STD_LOGIC;
    signal input_memory : INT8_MEMORY := (others => (others => '0'));
    signal weight_memory : INT8_MEMORY := (others => (others => '0'));
    signal bias_memory : WORD_MEMORY := (others => (others => '0'));
    signal output00, output01, output10, output11 : STD_LOGIC_VECTOR(31 downto 0);
    signal relu_enable, saturate_enable : STD_LOGIC := '0';
    signal done_latched, error_latched : STD_LOGIC := '0';
    signal irq_pulse : STD_LOGIC := '0';
    signal irq_enable : STD_LOGIC := '1';
    signal error_code : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal perf_cycles : unsigned(31 downto 0) := (others => '0');
    signal dimensions : STD_LOGIC_VECTOR(31 downto 0) := x"00020202";
    signal quant_shift : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal selected : STD_LOGIC;
    signal dimensions_valid : STD_LOGIC;
begin
    selected <= '1' when ADDR(31 downto 8) = x"000001" else '0';
    READY <= VALID and selected;
    ERROR <= VALID and (not selected or error_latched);
    IRQ <= irq_pulse;
    dimensions_valid <= '1' when dimensions(7 downto 0) = x"02" and
                                  dimensions(15 downto 8) = x"02" and
                                  dimensions(23 downto 16) = x"02" else '0';
    start <= '1' when VALID = '1' and WRITE = '1' and selected = '1' and
             ADDR(7 downto 0) = x"00" and WDATA(0) = '1' and
             array_busy = '0' and dimensions_valid = '1' else '0';

    U_ARRAY: entity work.NPU_ARRAY_2X2
        port map (
            CLK => CLK, RESET => RESET, START => start,
            A00 => input_memory(0), A01 => input_memory(1),
            A10 => input_memory(2), A11 => input_memory(3),
            B00 => weight_memory(0), B01 => weight_memory(1),
            B10 => weight_memory(2), B11 => weight_memory(3),
            BIAS0 => bias_memory(0), BIAS1 => bias_memory(1),
            DONE => array_done,
            RELU => relu_enable, SATURATE => saturate_enable,
            QUANT_SHIFT => quant_shift,
            BUSY => array_busy, ERROR => array_error,
            C00 => output00, C01 => output01, C10 => output10, C11 => output11
        );

    process(ADDR, array_busy, done_latched, error_latched, relu_enable,
            saturate_enable, error_code, irq_enable, perf_cycles,
            dimensions,
            quant_shift,
            output00, output01, output10, output11)
    begin
        RDATA <= (others => '0');
        if ADDR(7 downto 0) = x"04" then
            RDATA(0) <= array_busy;
            RDATA(1) <= done_latched;
            RDATA(2) <= error_latched;
        elsif ADDR(7 downto 0) = x"00" then
            RDATA(2) <= relu_enable;
            RDATA(3) <= saturate_enable;
        elsif ADDR(7 downto 0) = x"08" then
            RDATA <= error_code;
        elsif ADDR(7 downto 0) = x"30" then
            RDATA(0) <= irq_enable;
        elsif ADDR(7 downto 0) = x"34" then
            RDATA <= std_logic_vector(perf_cycles);
        elsif ADDR(7 downto 0) = x"20" then
            RDATA <= dimensions;
        elsif ADDR(7 downto 0) = x"2C" then
            RDATA(4 downto 0) <= quant_shift;
        elsif ADDR(7 downto 0) = x"10" then
            RDATA <= output00;
        elsif ADDR(7 downto 0) = x"14" then
            RDATA <= output01;
        elsif ADDR(7 downto 0) = x"18" then
            RDATA <= output10;
        elsif ADDR(7 downto 0) = x"1C" then
            RDATA <= output11;
        end if;
    end process;

    process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' then
                input_memory <= (others => (others => '0'));
                weight_memory <= (others => (others => '0'));
                bias_memory <= (others => (others => '0'));
                done_latched <= '0';
                error_latched <= '0';
                relu_enable <= '0';
                saturate_enable <= '0';
                irq_pulse <= '0';
                irq_enable <= '1';
                error_code <= (others => '0');
                perf_cycles <= (others => '0');
                dimensions <= x"00020202";
                quant_shift <= (others => '0');
            else
                irq_pulse <= '0';
                if array_busy = '1' then
                    perf_cycles <= perf_cycles + 1;
                end if;
                if array_done = '1' then
                    done_latched <= '1';
                    if irq_enable = '1' then
                        irq_pulse <= '1';
                    end if;
                end if;
                if array_error = '1' then
                    error_latched <= '1';
                    error_code <= x"00000001";
                end if;
                if VALID = '1' and WRITE = '1' and selected = '1' then
                    case ADDR(7 downto 0) is
                        when x"00" =>
                            relu_enable <= WDATA(2);
                            saturate_enable <= WDATA(3);
                            if WDATA(1) = '1' then
                                done_latched <= '0';
                                error_latched <= '0';
                                error_code <= (others => '0');
                            elsif WDATA(0) = '1' and array_busy = '1' then
                                error_latched <= '1';
                                error_code <= x"00000002";
                            elsif WDATA(0) = '1' and dimensions_valid = '0' then
                                error_latched <= '1';
                                error_code <= x"00000003";
                            end if;
                        when x"30" => irq_enable <= WDATA(0);
                        when x"20" => dimensions <= WDATA;
                        when x"2C" => quant_shift <= WDATA(4 downto 0);
                        when x"80" => input_memory(0) <= WDATA(7 downto 0);
                        when x"84" => input_memory(1) <= WDATA(7 downto 0);
                        when x"88" => input_memory(2) <= WDATA(7 downto 0);
                        when x"8C" => input_memory(3) <= WDATA(7 downto 0);
                        when x"90" => weight_memory(0) <= WDATA(7 downto 0);
                        when x"94" => weight_memory(1) <= WDATA(7 downto 0);
                        when x"98" => weight_memory(2) <= WDATA(7 downto 0);
                        when x"9C" => weight_memory(3) <= WDATA(7 downto 0);
                        when x"A0" => bias_memory(0) <= WDATA;
                        when x"A4" => bias_memory(1) <= WDATA;
                        when others => null;
                    end case;
                end if;
            end if;
        end if;
    end process;
end RTL;
