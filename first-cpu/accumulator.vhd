library ieee;
use ieee.std_logic_1164.all;

entity accumulator is
  port (
    clk : in std_logic;

    output_en : in std_logic;
    write_en : in std_logic;
    acc_sel : in std_logic;
    alu_in : in std_logic_vector(7 downto 0);
    bus_in : in std_logic_vector(7 downto 0);

    acc : out std_logic_vector(7 downto 0);
    bus_out : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of accumulator is
  signal acc_value : std_logic_vector(7 downto 0) := (others => '0');
  signal next_acc : std_logic_vector(7 downto 0);
begin
  next_acc <= alu_in when acc_sel else bus_in;

  bus_out <= acc_value when output_en else (others => 'Z');

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
