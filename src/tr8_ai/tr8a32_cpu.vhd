library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.TR8A32_ISA_PKG.ALL;

entity TR8A32_CPU is
    Port (
        CLK          : in  STD_LOGIC;
        RESET        : in  STD_LOGIC;
        INSTR_ADDR   : out WORD32;
        INSTR_DATA   : in  WORD32;
        DATA_VALID   : out STD_LOGIC;
        DATA_WRITE   : out STD_LOGIC;
        DATA_ADDR    : out WORD32;
        DATA_WDATA   : out WORD32;
        DATA_RDATA   : in  WORD32;
        DATA_READY   : in  STD_LOGIC;
        IRQ          : in  STD_LOGIC;
        HALTED       : out STD_LOGIC;
        DEBUG_PC     : out WORD32;
        DEBUG_STATE  : out STD_LOGIC_VECTOR(3 downto 0);
        DEBUG_MEPC   : out WORD32;
        DEBUG_MCAUSE : out WORD32
    );
end TR8A32_CPU;

architecture RTL of TR8A32_CPU is
    type STATE_TYPE is (FETCH, DECODE, EXECUTE, MEMORY, WRITEBACK);
    signal state : STATE_TYPE := FETCH;
    signal pc, instruction : WORD32 := (others => '0');
    signal rs1_value, rs2_value : WORD32;
    signal second_read_address : REG_ADDR := (others => '0');
    signal alu_a, alu_b, alu_result : WORD32;
    signal alu_op : STD_LOGIC_VECTOR(3 downto 0);
    signal alu_zero, alu_negative, alu_carry, alu_overflow : STD_LOGIC;
    signal reg_we : STD_LOGIC := '0';
    signal reg_waddr : REG_ADDR := (others => '0');
    signal reg_wdata : WORD32 := (others => '0');
    signal memory_load : STD_LOGIC := '0';
    signal memory_store : STD_LOGIC := '0';
    signal memory_address, memory_write_data : WORD32 := (others => '0');
    signal memory_read_data : WORD32 := (others => '0');
    signal branch_target : WORD32 := (others => '0');
    signal link_address : WORD32 := (others => '0');
    signal halted_state : STD_LOGIC := '0';
    signal trap_taken, eret : STD_LOGIC;
    signal mtvec, mepc, mcause : WORD32;
    signal register_reset : STD_LOGIC;
begin
    register_reset <= RESET;
    trap_taken <= '1' when (IRQ = '1' and state = FETCH) or
                           (state = EXECUTE and
                            instruction(31 downto 26) = OP_ECALL) else '0';
    eret <= '1' when state = EXECUTE and
                     instruction(31 downto 26) = OP_ERET else '0';

    U_REGISTERS: entity work.TR8A32_REGISTER_FILE
        port map (
            CLK => CLK,
            RESET => register_reset,
            WE => reg_we,
            WADDR => reg_waddr,
            WDATA => reg_wdata,
            RADDR1 => instruction(20 downto 16),
            RADDR2 => second_read_address,
            RDATA1 => rs1_value,
            RDATA2 => rs2_value
        );

    U_ALU: entity work.TR8A32_ALU
        port map (
            A => alu_a,
            B => alu_b,
            OP => alu_op,
            RESULT => alu_result,
            ZERO => alu_zero,
            NEGATIVE => alu_negative,
            CARRY => alu_carry,
            OVERFLOW => alu_overflow
        );

    U_CSR: entity work.TR8A32_CSR
        port map (
            CLK => CLK,
            RESET => RESET,
            IRQ => IRQ,
            TRAP_TAKEN => trap_taken,
            TRAP_PC => pc,
            TRAP_CAUSE => x"00000001",
            ERET => eret,
            MTVEC => mtvec,
            MEPC => mepc,
            MCAUSE => mcause
        );

    process(all)
        variable immediate : signed(31 downto 0);
        variable branch_offset : signed(31 downto 0);
    begin
        if instruction(31 downto 26) = OP_SW then
            second_read_address <= instruction(25 downto 21);
        else
            second_read_address <= instruction(15 downto 11);
        end if;
        alu_a <= rs1_value;
        alu_b <= rs2_value;
        alu_op <= ALU_ADD;
        immediate := resize(signed(instruction(15 downto 0)), 32);
        branch_offset := shift_left(resize(signed(instruction(15 downto 0)), 32), 2);
        branch_target <= std_logic_vector(signed(pc) + branch_offset);
        link_address <= std_logic_vector(unsigned(pc) + 4);

        case instruction(31 downto 26) is
            when OP_ALU_REG =>
                alu_op <= instruction(10 downto 7);
            when OP_ADDI | OP_LW | OP_SW =>
                alu_b <= std_logic_vector(immediate);
            when OP_LUI =>
                alu_b <= instruction(15 downto 0) & x"0000";
            when others =>
                null;
        end case;
    end process;

    process(CLK)
    begin
        if rising_edge(CLK) then
            reg_we <= '0';
            memory_load <= '0';
            memory_store <= '0';
            if RESET = '1' then
                pc <= (others => '0');
                instruction <= (others => '0');
                state <= FETCH;
                halted_state <= '0';
                memory_read_data <= (others => '0');
            elsif halted_state = '0' then
                if IRQ = '1' and state = FETCH then
                    trap_taken <= '1';
                    pc <= mtvec;
                    state <= FETCH;
                elsif state = EXECUTE and
                      instruction(31 downto 26) = OP_ERET then
                    eret <= '1';
                    pc <= mepc;
                    state <= FETCH;
                elsif state = EXECUTE and
                      instruction(31 downto 26) = OP_ECALL then
                    trap_taken <= '1';
                    pc <= mtvec;
                    state <= FETCH;
                else
                case state is
                    when FETCH =>
                        instruction <= INSTR_DATA;
                        state <= DECODE;
                    when DECODE =>
                        state <= EXECUTE;
                    when EXECUTE =>
                        case instruction(31 downto 26) is
                            when OP_BEQ =>
                                if rs1_value = rs2_value then
                                    pc <= branch_target;
                                else
                                    pc <= std_logic_vector(unsigned(pc) + 4);
                                end if;
                                state <= FETCH;
                            when OP_BNE =>
                                if rs1_value /= rs2_value then
                                    pc <= branch_target;
                                else
                                    pc <= std_logic_vector(unsigned(pc) + 4);
                                end if;
                                state <= FETCH;
                            when OP_JAL =>
                                pc <= branch_target;
                                reg_waddr <= instruction(25 downto 21);
                                reg_wdata <= link_address;
                                reg_we <= '1';
                                state <= FETCH;
                            when OP_LW | OP_SW =>
                                memory_address <= alu_result;
                                memory_write_data <= rs2_value;
                                memory_load <= '1' when instruction(31 downto 26) = OP_LW else '0';
                                memory_store <= '1' when instruction(31 downto 26) = OP_SW else '0';
                                state <= MEMORY;
                            when OP_HALT =>
                                halted_state <= '1';
                            when others =>
                                state <= WRITEBACK;
                        end case;
                    when MEMORY =>
                        if DATA_READY = '1' then
                            memory_read_data <= DATA_RDATA;
                            state <= WRITEBACK;
                        end if;
                    when WRITEBACK =>
                        if instruction(31 downto 26) = OP_ALU_REG or
                           instruction(31 downto 26) = OP_ADDI or
                           instruction(31 downto 26) = OP_LUI then
                            reg_waddr <= instruction(25 downto 21);
                            if instruction(31 downto 26) = OP_LUI then
                                reg_wdata <= instruction(15 downto 0) & x"0000";
                            else
                                reg_wdata <= alu_result;
                            end if;
                            reg_we <= '1';
                        elsif instruction(31 downto 26) = OP_LW then
                            reg_waddr <= instruction(25 downto 21);
                            reg_wdata <= memory_read_data;
                            reg_we <= '1';
                        end if;
                        pc <= std_logic_vector(unsigned(pc) + 4);
                        state <= FETCH;
                end case;
                end if;
            end if;
        end if;
    end process;

    INSTR_ADDR <= pc;
    DATA_VALID <= memory_load or memory_store;
    DATA_WRITE <= memory_store;
    DATA_ADDR <= memory_address;
    DATA_WDATA <= memory_write_data;
    HALTED <= halted_state;
    DEBUG_PC <= pc;
    DEBUG_STATE <= std_logic_vector(to_unsigned(STATE_TYPE'pos(state), 4));
    DEBUG_MEPC <= mepc;
    DEBUG_MCAUSE <= mcause;
end RTL;
