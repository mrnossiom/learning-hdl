use std.env.all;

library ieee;
use ieee.std_logic_1164.all;

library second_cpu;
use second_cpu.types.all;

entity cpu_tb is
end entity;

architecture sim of cpu_tb is
  signal rst, clk : std_logic := '1';
  signal dbg_mem : mem_array;
begin
  uut: entity second_cpu.cpu
    port map (
      clk => clk,
      rst => rst,
      dbg_mem => dbg_mem
    );

  clock: process
  begin
    loop
      clk <= not clk after HALF_CLK_PERIOD;
      wait for HALF_CLK_PERIOD;
    end loop;
  end process;

  initial: process
    variable status : boolean;
  begin
    rst <= '1', '0' after 1 * CLK_PERIOD;

    -- run for X cycles
    wait for 50 * CLK_PERIOD;

    status := dump_memory_to_file("cpu_tb.run.bin", dbg_mem);

    stop;
  end process;
end architecture;
