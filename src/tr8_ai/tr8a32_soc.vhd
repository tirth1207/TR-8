library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.TR8A32_ISA_PKG.ALL;

entity TR8A32_SOC is
    generic (
        PROGRAM : PROGRAM_ARRAY := (others => (others => '0'))
    );
    Port (
        CLK     : in  STD_LOGIC;
        RESET   : in  STD_LOGIC;
        HALTED  : out STD_LOGIC;
        DEBUG_PC : out WORD32;
        DEBUG_MEPC : out WORD32;
        DEBUG_MCAUSE : out WORD32;
        DEBUG_NPU_C00 : out WORD32;
        DEBUG_NPU_STATUS : out WORD32
    );
end TR8A32_SOC;

architecture RTL of TR8A32_SOC is
    signal instr_addr, instr_data : WORD32;
    signal data_valid, data_write, data_ready, data_error : STD_LOGIC;
    signal data_addr, data_wdata, data_rdata : WORD32;
    signal debug_state : STD_LOGIC_VECTOR(3 downto 0);
    signal timer_rdata : WORD32;
    signal timer_ready, timer_error, timer_valid, timer_write : STD_LOGIC;
    signal timer_irq : STD_LOGIC;
    signal npu_rdata : WORD32;
    signal npu_ready, npu_error, npu_valid, npu_write : STD_LOGIC;
    signal npu_irq : STD_LOGIC;
begin
    U_CPU: entity work.TR8A32_CPU
        port map (
            CLK => CLK,
            RESET => RESET,
            INSTR_ADDR => instr_addr,
            INSTR_DATA => instr_data,
            DATA_VALID => data_valid,
            DATA_WRITE => data_write,
            DATA_ADDR => data_addr,
            DATA_WDATA => data_wdata,
            DATA_RDATA => data_rdata,
            DATA_READY => data_ready,
            IRQ => timer_irq or npu_irq,
            HALTED => HALTED,
            DEBUG_PC => DEBUG_PC,
            DEBUG_STATE => debug_state,
            DEBUG_MEPC => DEBUG_MEPC,
            DEBUG_MCAUSE => DEBUG_MCAUSE
        );

    U_MEMORY: entity work.TR8A32_MEMORY
        generic map (PROGRAM => PROGRAM)
        port map (
            CLK => CLK,
            RESET => RESET,
            INSTR_ADDR => instr_addr,
            INSTR_DATA => instr_data,
            DATA_VALID => data_valid,
            DATA_WRITE => data_write,
            DATA_ADDR => data_addr,
            DATA_WDATA => data_wdata,
            DATA_RDATA => data_rdata,
            DATA_READY => data_ready,
            DATA_ERROR => data_error,
            TIMER_RDATA => timer_rdata,
            TIMER_READY => timer_ready,
            TIMER_ERROR => timer_error,
            TIMER_VALID => timer_valid,
            TIMER_WRITE => timer_write,
            NPU_RDATA => npu_rdata,
            NPU_READY => npu_ready,
            NPU_ERROR => npu_error,
            NPU_VALID => npu_valid,
            NPU_WRITE => npu_write
        );

    U_TIMER: entity work.TR8A32_TIMER
        port map (
            CLK => CLK,
            RESET => RESET,
            VALID => timer_valid,
            WRITE => timer_write,
            ADDR => data_addr,
            WDATA => data_wdata,
            RDATA => timer_rdata,
            READY => timer_ready,
            ERROR => timer_error,
            IRQ => timer_irq
        );

    U_NPU: entity work.NPU_CONTROLLER
        port map (
            CLK => CLK,
            RESET => RESET,
            VALID => npu_valid,
            WRITE => npu_write,
            ADDR => data_addr,
            WDATA => data_wdata,
            RDATA => npu_rdata,
            READY => npu_ready,
            ERROR => npu_error,
            IRQ => npu_irq
        );

    DEBUG_NPU_C00 <= npu_rdata when data_addr(7 downto 0) = x"10" else
                     (others => '0');
    DEBUG_NPU_STATUS <= npu_rdata when data_addr(7 downto 0) = x"04" else
                        (others => '0');
end RTL;
