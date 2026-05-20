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

  clock: process
  begin
    loop
      clk <= not clk after HALF_CLK_PERIOD;
      wait for HALF_CLK_PERIOD;
    end loop;
  end process;

  initial: process
  begin
    reset <= '1', '0' after CLK_PERIOD;

    -- exec 10 instructions
    wait for 10 * CLK_PERIOD;

    stop;
  end process;
end architecture;
