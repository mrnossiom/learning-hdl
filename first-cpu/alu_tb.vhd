library ieee;
use ieee.std_logic_1164.all;
use work.custom_cpu_types.all;

entity alu_tb is
end entity;

architecture sim of alu_tb is
  signal acc : std_logic_vector(7 downto 0);
  signal bus_in : std_logic_vector(7 downto 0);
  signal alu_op : std_logic_vector(3 downto 0);

  signal result : std_logic_vector(7 downto 0);
  signal alu_carry : std_logic;
  signal ext_result : std_logic_vector(7 downto 0);
begin
  uut: entity work.alu(rtl)
    port map (
      acc => acc,
      bus_in => bus_in,
      alu_op => alu_op,
      result => result,
      alu_carry => alu_carry,
      ext_result => ext_result
    );

  process
  begin
    acc <= x"01"; bus_in <= x"01"; alu_op <= from_alu_op(OP_ADD); wait for 10 ns;
    assert (result = x"02") report "addition failed";

    acc <= x"01"; bus_in <= x"01"; alu_op <= from_alu_op(OP_SUB); wait for 10 ns;
    assert (result = x"02") report "substraction failed";

    report "simulation ended" severity note;
    wait;
  end process;
end architecture;
