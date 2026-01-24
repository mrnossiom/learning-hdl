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
  constant alu_op_add : alu_op := x"1";
  constant alu_op_sub : alu_op := x"2";
  constant alu_op_mul : alu_op := x"3";
  constant alu_op_and : alu_op := x"4";
  constant alu_op_xor : alu_op := x"5";
  -- left/right shift and their car0ry counterparts
  constant alu_op_ls : alu_op := x"6";
  constant alu_op_rs : alu_op := x"7";
  constant alu_op_cls : alu_op := x"8";
  constant alu_op_crs : alu_op := x"9";
  -- arithmetic right shift
  constant alu_op_asr : alu_op := x"A";
  constant alu_op_inc : alu_op := x"B";
  constant alu_op_dec : alu_op := x"C";

  subtype cpu_addr is std_logic_vector(7 downto 0);

  subtype cpu_word is std_logic_vector(7 downto 0);
  subtype cpu_bit_word is bit_vector(7 downto 0);
end package;

package body types is
  function mem_high_addr(m : memory) return natural is
  begin
    return (m / 1 b) - 1;
  end function;
end package body;
