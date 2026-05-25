library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library first_cpu;
use first_cpu.types.all;

entity regfile is
  port (
    clk : in std_logic;
    read_en, write_en : in std_logic;
    read_num, write_num : in cpu_regnum;
    data_bus : inout cpu_word
  );
end entity;

architecture rtl of regfile is
    type reg_array is
      array (natural range 0 to 15) of cpu_word;

    signal regs : reg_array := (others => x"00");
begin
  data_bus <= regs(to_integer(unsigned(read_num))) when read_en else (others => 'Z');

  process(all)
  begin
    if falling_edge(clk) then
      if write_en then
        regs(to_integer(unsigned(write_num))) <= data_bus;
      end if;
    end if;
  end process;
end architecture;
