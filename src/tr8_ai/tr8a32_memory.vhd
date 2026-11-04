library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.TR8A32_ISA_PKG.ALL;

entity TR8A32_MEMORY is
    generic (
        PROGRAM_WORDS : positive := 256;
        DATA_WORDS    : positive := 256;
        PROGRAM       : PROGRAM_ARRAY := (others => (others => '0'))
    );
    Port (
        CLK         : in  STD_LOGIC;
        RESET       : in  STD_LOGIC;
        INSTR_ADDR  : in  WORD32;
        INSTR_DATA  : out WORD32;
        DATA_VALID  : in  STD_LOGIC;
        DATA_WRITE  : in  STD_LOGIC;
        DATA_ADDR   : in  WORD32;
        DATA_WDATA  : in  WORD32;
        DATA_RDATA  : out WORD32;
        DATA_READY  : out STD_LOGIC;
        DATA_ERROR  : out STD_LOGIC;
        TIMER_RDATA : in  WORD32;
        TIMER_READY : in  STD_LOGIC;
        TIMER_ERROR : in  STD_LOGIC;
        TIMER_VALID : out STD_LOGIC;
        TIMER_WRITE : out STD_LOGIC;
        NPU_RDATA   : in  WORD32;
        NPU_READY   : in  STD_LOGIC;
        NPU_ERROR   : in  STD_LOGIC;
        NPU_VALID   : out STD_LOGIC;
        NPU_WRITE   : out STD_LOGIC
    );
end TR8A32_MEMORY;

architecture RTL of TR8A32_MEMORY is
    type PROGRAM_ARRAY is array (0 to PROGRAM_WORDS - 1) of WORD32;
    type DATA_ARRAY is array (0 to DATA_WORDS - 1) of WORD32;
    signal program_memory : PROGRAM_ARRAY := (others => (others => '0'));
    signal data_memory : DATA_ARRAY := (others => (others => '0'));
    signal instr_index : natural range 0 to PROGRAM_WORDS - 1 := 0;
    signal data_index : natural range 0 to DATA_WORDS - 1 := 0;
    signal data_in_range : STD_LOGIC;
    signal instr_in_range : STD_LOGIC;
begin
    instr_in_range <= '1' when unsigned(INSTR_ADDR(31 downto 2)) < to_unsigned(PROGRAM_WORDS, 30) else '0';
    instr_index <= to_integer(unsigned(INSTR_ADDR(31 downto 2))) when instr_in_range = '1' else 0;
    data_in_range <= '1' when unsigned(DATA_ADDR(31 downto 10)) = 0 and DATA_ADDR(9 downto 8) = "00" and
                              to_integer(unsigned(DATA_ADDR(9 downto 2))) < DATA_WORDS else '0';
    data_index <= to_integer(unsigned(DATA_ADDR(9 downto 2))) when data_in_range = '1' else 0;

    INSTR_DATA <= PROGRAM(instr_index) when instr_in_range = '1' else (others => '0');
    TIMER_VALID <= DATA_VALID when unsigned(DATA_ADDR(31 downto 4)) = x"0000040" else '0';
    TIMER_WRITE <= DATA_WRITE;
    NPU_VALID <= DATA_VALID when DATA_ADDR(31 downto 8) = x"000001" else '0';
    NPU_WRITE <= DATA_WRITE;
    DATA_RDATA <= NPU_RDATA when NPU_VALID = '1' else
                  TIMER_RDATA when TIMER_VALID = '1' else
                  data_memory(data_index) when data_in_range = '1' else
                  (others => '0');
    DATA_READY <= NPU_READY when NPU_VALID = '1' else
                  TIMER_READY when TIMER_VALID = '1' else DATA_VALID;
    DATA_ERROR <= NPU_ERROR when NPU_VALID = '1' else
                  TIMER_ERROR when TIMER_VALID = '1' else
                  DATA_VALID and not data_in_range;

    process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' then
                data_memory <= (others => (others => '0'));
            elsif DATA_VALID = '1' and DATA_WRITE = '1' and
                  data_in_range = '1' then
                data_memory(data_index) <= DATA_WDATA;
            end if;
        end if;
    end process;
end RTL;
