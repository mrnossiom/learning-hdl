library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.types.all;

entity alu is
  port (
    acc : in cpu_word;
    bus_in : in cpu_word;
    alu_op : in alu_op;

    result : out cpu_word;
    alu_carry : out std_logic;
    ext_result : out cpu_word
  );
end entity;

architecture rtl of alu is
begin
  process(all)
    variable res_9bit : unsigned(8 downto 0);
    variable res_16bit : unsigned(15 downto 0);
  begin
    result <= acc;
    alu_carry <= '0';
    ext_result <= (others => '0');

    case alu_op is
      when alu_op_add =>
        res_9bit := unsigned('0' & acc) + unsigned('0' & bus_in);
        result <= cpu_word(res_9bit(7 downto 0));
        alu_carry <= res_9bit(8);
      when alu_op_sub =>
        res_9bit := unsigned('0' & acc) - unsigned('0' & bus_in);
        result <= cpu_word(res_9bit(7 downto 0));
        alu_carry <= res_9bit(8);
      when alu_op_mul =>
        res_16bit := unsigned(acc) * unsigned(bus_in);
        result <= cpu_word(res_16bit(7 downto 0));
        ext_result <= cpu_word(res_16bit(15 downto 8));

      when alu_op_and => result <= acc and bus_in;
      when alu_op_xor => result <= acc xor bus_in;
      when alu_op_ls => result <= acc(6 downto 0) & '0';
      when alu_op_rs => result <= '0' & acc(7 downto 1);
      when alu_op_cls => result <= acc(6 downto 0) & acc(7);
      when alu_op_crs => result <= acc(0) & acc(7 downto 1);
      when alu_op_asr => result <= acc(7) & acc(7 downto 1);

      when alu_op_inc =>
        res_9bit := unsigned('0' & acc) + 1;
        result <= cpu_word(res_9bit(7 downto 0));
        alu_carry <= res_9bit(8);
      when alu_op_dec =>
        res_9bit := unsigned('0' & acc) - 1;
        result <= cpu_word(res_9bit(7 downto 0));
        alu_carry <= res_9bit(8);

      when others =>
        report "illegal alu operation" severity failure;
    end case;
  end process;
end architecture;
