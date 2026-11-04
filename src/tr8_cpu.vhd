library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.TR8_ISA_PKG.ALL;

entity TR8_CPU is
    generic (
        PROGRAM : ROM_ARRAY := SAMPLE_PROGRAM
    );
    Port (
        CLK                 : in  STD_LOGIC;
        RESET               : in  STD_LOGIC;
        PC_OUT              : out STD_LOGIC_VECTOR(7 downto 0);
        CURRENT_INSTRUCTION : out STD_LOGIC_VECTOR(15 downto 0);
        HALTED              : out STD_LOGIC;
        DEBUG_R0            : out STD_LOGIC_VECTOR(7 downto 0);
        DEBUG_R1            : out STD_LOGIC_VECTOR(7 downto 0);
        DEBUG_R2            : out STD_LOGIC_VECTOR(7 downto 0);
        DEBUG_R3            : out STD_LOGIC_VECTOR(7 downto 0);
        DEBUG_ZERO          : out STD_LOGIC;
        DEBUG_RAM_ADDR      : out STD_LOGIC_VECTOR(7 downto 0);
        DEBUG_RAM_DATA      : out STD_LOGIC_VECTOR(7 downto 0);
        DEBUG_OPCODE        : out STD_LOGIC_VECTOR(3 downto 0);
        DEBUG_RD            : out STD_LOGIC_VECTOR(1 downto 0);
        DEBUG_RS            : out STD_LOGIC_VECTOR(1 downto 0);
        DEBUG_IMMEDIATE     : out STD_LOGIC_VECTOR(7 downto 0);
        DEBUG_ALU_A         : out STD_LOGIC_VECTOR(7 downto 0);
        DEBUG_ALU_B         : out STD_LOGIC_VECTOR(7 downto 0);
        DEBUG_ALU_SEL       : out STD_LOGIC_VECTOR(2 downto 0);
        DEBUG_ALU_RESULT    : out STD_LOGIC_VECTOR(7 downto 0);
        DEBUG_REG_WE        : out STD_LOGIC;
        DEBUG_REG_WADDR     : out STD_LOGIC_VECTOR(1 downto 0);
        DEBUG_REG_WDATA     : out STD_LOGIC_VECTOR(7 downto 0);
        DEBUG_RAM_WE        : out STD_LOGIC
    );
end TR8_CPU;

architecture RTL of TR8_CPU is
    signal pc : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal instruction : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal opcode : STD_LOGIC_VECTOR(3 downto 0);
    signal rd, rs : STD_LOGIC_VECTOR(1 downto 0);
    signal immediate : STD_LOGIC_VECTOR(7 downto 0);
    signal rdata1, rdata2 : STD_LOGIC_VECTOR(7 downto 0);
    signal r0, r1, r2, r3 : STD_LOGIC_VECTOR(7 downto 0);
    signal alu_sel : STD_LOGIC_VECTOR(2 downto 0);
    signal alu_result, ram_data : STD_LOGIC_VECTOR(7 downto 0);
    signal alu_zero : STD_LOGIC;
    signal reg_we, ram_we, jump, halt_control : STD_LOGIC;
    signal reg_waddr, reg_waddr_control : STD_LOGIC_VECTOR(1 downto 0);
    signal wb_sel : STD_LOGIC_VECTOR(1 downto 0);
    signal reg_wdata : STD_LOGIC_VECTOR(7 downto 0);
    signal zero_flag, halted_state : STD_LOGIC := '0';
    signal effective_jump : STD_LOGIC;
begin
    opcode    <= instruction(15 downto 12);
    rd        <= instruction(11 downto 10);
    rs        <= instruction(9 downto 8);
    immediate <= instruction(7 downto 0);
    reg_waddr <= reg_waddr_control;

    effective_jump <= jump when halted_state = '0' else '0';

    with wb_sel select
        reg_wdata <= immediate  when "01",
                     ram_data   when "10",
                     alu_result when others;

    U_PC: entity work.PROGRAM_COUNTER
        port map (CLK, RESET, not halted_state and not halt_control, effective_jump,
                  immediate, pc);

    U_ROM: entity work.INSTRUCTION_ROM
        generic map (PROGRAM => PROGRAM)
        port map (pc, instruction);

    U_CONTROL: entity work.CONTROL_UNIT
        port map (opcode, rd, zero_flag, alu_sel, reg_we, reg_waddr_control,
                  wb_sel, ram_we, jump, halt_control);

    U_REGISTERS: entity work.REGISTER_FILE
        port map (CLK, RESET, reg_we and not halted_state, reg_waddr, reg_wdata,
                  rd, rs, rdata1, rdata2, r0, r1, r2, r3);

    U_ALU: entity work.ALU
        port map (rdata1, rdata2, alu_sel, alu_result, alu_zero);

    U_RAM: entity work.DATA_RAM
        port map (CLK, RESET, ram_we and not halted_state, immediate, rdata1, ram_data);

    process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' then
                zero_flag    <= '0';
                halted_state <= '0';
            elsif halted_state = '0' then
                if reg_we = '1' then
                    zero_flag <= '1' when reg_wdata = x"00" else '0';
                end if;
                if halt_control = '1' then
                    halted_state <= '1';
                end if;
            end if;
        end if;
    end process;

    PC_OUT              <= pc;
    CURRENT_INSTRUCTION <= instruction;
    HALTED              <= halted_state;
    DEBUG_R0            <= r0;
    DEBUG_R1            <= r1;
    DEBUG_R2            <= r2;
    DEBUG_R3            <= r3;
    DEBUG_ZERO          <= zero_flag;
    DEBUG_RAM_ADDR      <= immediate;
    DEBUG_RAM_DATA      <= ram_data;
    DEBUG_OPCODE        <= opcode;
    DEBUG_RD            <= rd;
    DEBUG_RS            <= rs;
    DEBUG_IMMEDIATE     <= immediate;
    DEBUG_ALU_A         <= rdata1;
    DEBUG_ALU_B         <= rdata2;
    DEBUG_ALU_SEL       <= alu_sel;
    DEBUG_ALU_RESULT    <= alu_result;
    DEBUG_REG_WE        <= reg_we and not halted_state;
    DEBUG_REG_WADDR     <= reg_waddr;
    DEBUG_REG_WDATA     <= reg_wdata;
    DEBUG_RAM_WE        <= ram_we and not halted_state;
end RTL;
