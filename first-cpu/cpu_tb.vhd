use std.env.all;

library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

entity cpu_tb is
end entity;

architecture sim of cpu_tb is
  signal clk, reset : std_logic := '0';
begin
  uut: entity work.cpu
    port map (
      clk => clk,
      reset => reset
    );

  clock : process
  begin
    loop
      -- 1 MHz
      clk <= not clk after 1 us;
      wait for 1 us;
    end loop;
  end process;
end architecture;

