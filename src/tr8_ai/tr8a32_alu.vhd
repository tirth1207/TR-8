library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.TR8A32_ISA_PKG.ALL;

entity TR8A32_ALU is
    Port (
        A        : in  WORD32;
        B        : in  WORD32;
        OP       : in  STD_LOGIC_VECTOR(3 downto 0);
        RESULT   : out WORD32;
        ZERO     : out STD_LOGIC;
        NEGATIVE : out STD_LOGIC;
        CARRY    : out STD_LOGIC;
        OVERFLOW : out STD_LOGIC
    );
end TR8A32_ALU;

architecture RTL of TR8A32_ALU is
    signal result_i : WORD32;
    signal extended : STD_LOGIC_VECTOR(32 downto 0);
begin
    process(A, B, OP)
        variable a_signed : signed(31 downto 0);
        variable b_signed : signed(31 downto 0);
        variable sum : signed(32 downto 0);
        variable diff : signed(32 downto 0);
        variable shift_amount : natural range 0 to 31;
    begin
        result_i <= (others => '0');
        extended <= (others => '0');
        a_signed := signed(A);
        b_signed := signed(B);
        shift_amount := to_integer(unsigned(B(4 downto 0)));

        case OP is
            when ALU_ADD =>
                sum := resize(a_signed, 33) + resize(b_signed, 33);
                result_i <= std_logic_vector(sum(31 downto 0));
                extended <= std_logic_vector(resize(unsigned(A), 33) +
                                              resize(unsigned(B), 33));
            when ALU_SUB =>
                diff := resize(a_signed, 33) - resize(b_signed, 33);
                result_i <= std_logic_vector(diff(31 downto 0));
                extended <= std_logic_vector(resize(unsigned(A), 33) -
                                              resize(unsigned(B), 33));
            when ALU_AND =>
                result_i <= A and B;
            when ALU_OR =>
                result_i <= A or B;
            when ALU_XOR =>
                result_i <= A xor B;
            when ALU_SLL =>
                result_i <= std_logic_vector(shift_left(unsigned(A), shift_amount));
            when ALU_SRL =>
                result_i <= std_logic_vector(shift_right(unsigned(A), shift_amount));
            when ALU_SRA =>
                result_i <= std_logic_vector(shift_right(signed(A), shift_amount));
            when ALU_SLT =>
                if a_signed < b_signed then
                    result_i(0) <= '1';
                end if;
            when ALU_SLTU =>
                if unsigned(A) < unsigned(B) then
                    result_i(0) <= '1';
                end if;
            when others =>
                null;
        end case;
    end process;

    RESULT <= result_i;
    ZERO <= '1' when result_i = x"00000000" else '0';
    NEGATIVE <= result_i(31);
    CARRY <= extended(32) when OP = ALU_ADD else
             not extended(32) when OP = ALU_SUB else
             '0';
    OVERFLOW <=
        ((not (A(31) xor B(31))) and (A(31) xor result_i(31))) when OP = ALU_ADD else
        ((A(31) xor B(31)) and (A(31) xor result_i(31))) when OP = ALU_SUB else
        '0';
end RTL;
