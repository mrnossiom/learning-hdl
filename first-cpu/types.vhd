library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package types is
  type memory is range 0 to 1E10
    units
      b;
      kb = 1000 b;
      mb = 1000 kb;
      gb = 1000 mb;
      kib = 1024 b;
      mib = 1024 kib;
      gib = 1024 mib;
    end units;

  function mem_high_addr(m : memory) return natural;

  ---

  subtype alu_op is std_logic_vector(3 downto 0);
  constant alu_op_add : alu_op := b"0000";
  constant alu_op_sub : alu_op := b"0001";
  constant alu_op_mul : alu_op := b"0010";
  constant alu_op_and : alu_op := b"0011";
  constant alu_op_or  : alu_op := b"0100";
  constant alu_op_xor : alu_op := b"0101";

  -- left/right shift and their carry counterparts
  constant alu_op_ls  : alu_op := b"1000";
  constant alu_op_rs  : alu_op := b"1001";
  constant alu_op_cls : alu_op := b"1010";
  constant alu_op_crs : alu_op := b"1011";
  -- arithmetic right shift
  constant alu_op_asr : alu_op := b"1100";
  constant alu_op_inc : alu_op := b"1101";
  constant alu_op_dec : alu_op := b"1110";

  subtype cpu_addr is std_logic_vector(7 downto 0);

  subtype cpu_word is std_logic_vector(7 downto 0);
  subtype cpu_bit_word is bit_vector(7 downto 0);

  subtype cpu_instr is std_logic_vector(7 downto 0);
  subtype cpu_instr_opcode is std_logic_vector(7 downto 4);

  -- Reg
  constant instr_opcode_alu_rn    : cpu_instr_opcode := b"0ZZZ";
  constant instr_opcode_cp_acc_rn : cpu_instr_opcode := b"1000";
  constant instr_opcode_cp_rn_acc : cpu_instr_opcode := b"1001";
  constant instr_opcode_cmp_rn    : cpu_instr_opcode := b"1010";

  -- Imm
  constant instr_opcode_branch  : cpu_instr_opcode := b"1011";
  constant instr_opcode_beq     : cpu_instr_opcode := b"1100";
  constant instr_opcode_lli_imm : cpu_instr_opcode := b"1101";
  constant instr_opcode_lui_imm : cpu_instr_opcode := b"1110";

  constant instr_opcode_custom : cpu_instr_opcode := b"1111";

  constant instr_custom_alu  : cpu_instr_opcode := b"1ZZZ";
  constant instr_custom_nop  : cpu_instr_opcode := b"0000";
  constant instr_custom_halt : cpu_instr_opcode := b"0111";
end package;

package body types is
  function mem_high_addr(m : memory) return natural is
  begin
    return (m / 1 b) - 1;
  end function;
end package body;
