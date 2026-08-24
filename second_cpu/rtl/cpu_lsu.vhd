library ieee;
use ieee.std_logic_1164.all;

library second_cpu;
use second_cpu.types.all;

entity cpu_lsu is
  port (
    clk, rst : in std_ulogic;

    mem_address : out cpu_addr;
    mem_data : in cpu_word;
    mem_strobe : out std_logic;
    mem_mode : out mem_mode;
    mem_ready : in std_logic
  );
end entity;

architecture rtl of cpu_lsu is
begin
end architecture;
