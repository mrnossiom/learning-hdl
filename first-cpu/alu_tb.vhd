use std.env.all;

library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

entity alu_tb is
end entity;

architecture sim of alu_tb is
  signal acc : cpu_word;
  signal bus_in : cpu_word;
  signal alu_op : cpu_alu_op := alu_op_add;

  signal result : cpu_word;
  signal alu_carry : std_logic;
  signal extd_result : cpu_word;
begin
  uut: entity work.alu(rtl)
    port map (
      acc => acc,
      bus_in => bus_in,
      alu_op => alu_op,
      result => result,
      alu_carry => alu_carry,
      extended_result => extd_result
    );

  process
  begin
    acc <= x"01"; bus_in <= x"01"; alu_op <= alu_op_add; wait for 10 fs;
    assert (result = x"02") report "addition failed";

    acc <= x"01"; bus_in <= x"01"; alu_op <= alu_op_sub; wait for 10 fs;
    assert (result = x"00") report "substraction failed";

    stop;
  end process;
end architecture;
