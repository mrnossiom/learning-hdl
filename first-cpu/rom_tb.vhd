use std.env.all;

library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

entity rom_tb is
begin
end entity;

architecture sim of rom_tb is
  signal clk : std_logic := '0';
  signal address : cpu_addr;
  signal instr : cpu_word;
begin
  uut: entity work.rom(file_preloaded)
    generic map (
      load_filename => "rom_tb.bin",
      mem_size => 1 kib
    )
    port map (
      clk => clk,
      address => address,
      instr => instr
    );

  process
  begin
    -- TODO: take clk into account
    address <= x"00"; wait for 2 us;
    report to_hex_string(instr);
    address <= x"01"; wait for 2 us;
    report to_hex_string(instr);
    address <= x"02"; wait for 2 us;
    report to_hex_string(instr);
    address <= x"22"; wait for 2 us;
    report to_hex_string(instr);

    wait for 2 us;
    stop;
  end process;
end architecture;
