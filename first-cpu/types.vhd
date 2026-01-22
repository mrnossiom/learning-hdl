library ieee;
use ieee.std_logic_1164.all;

package custom_cpu_types is
  type alu_op_t is (
    OP_ADD, OP_SUB, OP_MUL,

    OP_AND, OP_XOR,
    -- left/right shift and their carry counterparts
    OP_LS, OP_RS, OP_CLS, OP_CRS,
    -- arithmetic right shift
    OP_ASR,
    OP_INC, OP_DEC,
    OP_UNKNOWN
  );

  function from_alu_op(s : alu_op_t) return std_logic_vector;
  function to_alu_op(s : std_logic_vector(3 downto 0)) return alu_op_t;
end package;

package body custom_cpu_types is
  function to_alu_op(s : std_logic_vector(3 downto 0)) return alu_op_t is
  begin
    case s is
      when "0000" => return OP_ADD;
      when "0001" => return OP_SUB;
      when "0010" => return OP_MUL;
      when "0011" => return OP_AND;
      when "0100" => return OP_XOR;
      when "0101" => return OP_LS;
      when "0110" => return OP_RS;
      when "1000" => return OP_CLS;
      when "0111" => return OP_CRS;
      when "1001" => return OP_ASR;
      when "1010" => return OP_INC;
      when "1011" => return OP_DEC;
      when others => return OP_UNKNOWN;
    end case;
  end function;

  function from_alu_op(s : alu_op_t) return std_logic_vector is
  begin
    case s is
      when OP_ADD => return "0000";
      when OP_SUB => return "0001";
      when OP_MUL => return "0010";
      when OP_AND => return "0011";
      when OP_XOR => return "0100";
      when OP_LS => return "0101";
      when OP_RS => return "0110";
      when OP_CLS => return "1000";
      when OP_CRS => return "0111";
      when OP_ASR => return "1001";
      when OP_INC => return "1010";
      when OP_DEC => return "1011";
      when OP_UNKNOWN => report "unreachable";
    end case;
  end function;
end package body;
