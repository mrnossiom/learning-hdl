library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library second_cpu;
use second_cpu.types.all;

entity cpu_fetch is
  port (
    rst, clk : in std_logic;
    state : in cpu_state;

    pc : in cpu_addr;

    mem_address : out cpu_addr;
    mem_data : in cpu_word;
    mem_strobe : out std_logic;
    mem_mode : out mem_mode;
    mem_ready : in std_logic;

    ready : out std_logic;
    instruction : out cpu_word
  );
end entity;

architecture rtl of cpu_fetch is
  type fetch_state is (IDLE, MEM_WAIT, DONE);
  signal fstate : fetch_state := IDLE;
begin
  process(rst, clk)
  begin
    if rst then
      mem_address <= (others => '0');
      mem_strobe <= '0';
      mem_mode <= READ;

      ready <= '1';
      instruction <= (others => '0');
    elsif rising_edge(clk) then
      case fstate is
        when IDLE =>
          if state = S_FETCH then
            mem_address <= pc;
            mem_mode <= READ;

            fstate <= MEM_WAIT;
          end if;
        when MEM_WAIT =>
          if mem_ready then
            mem_address <= (others => 'Z');

            ready <= '1';
            instruction <= mem_data;

            fstate <= DONE;
          end if;
        when DONE =>
          ready <= '0';
          fstate <= IDLE;
      end case;
    end if;
  end process;
end architecture;
