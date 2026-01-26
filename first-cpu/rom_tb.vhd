use std.env.all;

library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

entity rom_tb is
begin
end entity;

architecture sim of rom_tb is
  signal address : cpu_addr;
  signal data : cpu_word;
begin
  uut: entity work.rom(file_preloaded)
    generic map (
      load_filename => "rom_tb.bin",
      mem_size => 1 kib
    )
    port map (
      address => address,
      data => data
    );

  process
  begin
    address <= x"00"; wait for 2 us;
    report to_hex_string(data);
    address <= x"01"; wait for 2 us;
    report to_hex_string(data);
    address <= x"02"; wait for 2 us;
    report to_hex_string(data);
    address <= x"22"; wait for 2 us;
    report to_hex_string(data);

    wait for 2 us;
    stop;
  end process;
end architecture;
