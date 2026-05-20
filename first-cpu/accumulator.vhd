library ieee;
use ieee.std_logic_1164.all;
use work.types.all;

entity accumulator is
  port (
    clk : in std_logic;

    output_en : in std_logic;
    write_en : in std_logic;
    sel_alu : in std_logic;
    alu_in : in cpu_word;

    data_bus : inout cpu_word;

    acc : out cpu_word
  );
end entity;

architecture rtl of accumulator is
  signal acc_value : cpu_word := (others => '0');
  signal next_acc : cpu_word;
begin
  next_acc <= alu_in when sel_alu else data_bus;

  data_bus <= acc_value when output_en else (others => 'Z');

  acc <= acc_value;

  process(clk)
  begin
    if rising_edge(clk) then
      if (write_en) then
        acc_value <= next_acc;
      end if;
    end if;
  end process;
end architecture;
