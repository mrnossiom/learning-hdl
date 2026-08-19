library ieee;

use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library second_cpu;
use second_cpu.types.all;

entity ram is
  generic (
    latency : natural := 2;
    load_filename : string
  );
  port (
    clk, rst : in std_logic;

    address : in cpu_addr;
    strobe : in std_logic;
    mode : in mem_mode;

    ready : out std_logic;
    data : inout cpu_word;

    dbg_mem : out mem_array
  );
end entity;

architecture file_preloaded of ram is
  signal memory : mem_array := load_memory_from_file(load_filename);

  type mem_state is (IDLE, BUSY, DONE);
  signal mstate : mem_state := IDLE;
  signal cycle_count : natural;
begin
  dbg_mem <= memory;

  process(rst, clk)
  begin
    if rst then
      ready <= '1';
      data <= (others => 'Z');

      mstate <= IDLE;
      cycle_count <= 0;
    elsif rising_edge(clk) then
      case mstate is
        when IDLE =>
          ready <= '0';

          if strobe then
            if latency = 1 then
              -- instant fetch
              mstate <= DONE;
            else
              cycle_count <= 1;
              mstate <= BUSY;
            end if;
          end if;
        when BUSY =>
          if cycle_count = latency then
            ready <= '1';
            case mode is
              when READ =>
                data <= to_x01(memory(to_integer(unsigned(address))));
              when WRITE =>
                memory(to_integer(unsigned(address))) <= data;
            end case;

            mstate <= DONE;
          else
            cycle_count <= cycle_count + 1;
          end if;
        when DONE =>
          ready <= '0';
          data <= (others => 'Z');
          mstate <= IDLE;
        end case;
    end if;
  end process;
end architecture;
