library ieee;

use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity rom is
  generic (
    mem_size : memory;
    load_filename : string
  );
  port (
    clk : in std_logic;
    address : in cpu_addr;
    instr : inout cpu_word
  );
end entity;

architecture file_preloaded of rom is
    constant HIGH_ADDRESS : natural := mem_high_addr(mem_size);
    type mem_array is
      array (natural range 0 to HIGH_ADDRESS) of cpu_word;

    impure function load_initial return mem_array is
      file binary_file : text open read_mode is load_filename;
      variable buf : line;
      variable bit_word : cpu_word;
      variable mem : mem_array := (others => x"00");
      variable addr : natural := 0;
    begin
      while not endfile(binary_file) loop
        readline(binary_file, buf);
        binary_read(buf, bit_word);

        mem(addr) := cpu_word(to_x01(bit_word));
        addr := addr + 1;
      end loop;
      return mem;
    end function;

    constant MEM : mem_array := load_initial;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      instr <= to_x01(MEM(to_integer(unsigned(address))));
    end if;
  end process;
end architecture;
