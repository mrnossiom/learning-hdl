library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

entity rom_tb is
begin
end entity;

architecture sim of rom_tb is
  signal clk : std_logic;
  signal address : cpu_addr := x"00";
  signal data : cpu_word;
begin
  uut: entity work.rom(file_preloaded)
    generic map (
      load_filename => "rom_tb.bin",
      mem_size => 1 kib
    )
    port map (
      clk => clk,
      address => address,
      data => data
    );

  clk <= '0', not clk after 1 ns;

  process
  begin
    address <= x"00"; wait for 10 ns;
    report to_hex_string(data);
    address <= x"01"; wait for 10 ns;
    report to_hex_string(data);
    address <= x"02"; wait for 10 ns;
    report to_hex_string(data);
    address <= x"22"; wait for 10 ns;
    report to_hex_string(data);

    report "simulation ended" severity note;
    wait;
  end process;
end architecture;
