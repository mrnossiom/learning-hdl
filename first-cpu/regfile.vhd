library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

entity regfile is
  port (
    clk : in std_logic;
    read_en, write_en : in std_logic;
    read_num, write_num : in cpu_rn;
    bus_io : inout cpu_word

  );
end entity;

architecture rtl of regfile is
begin
end architecture;
