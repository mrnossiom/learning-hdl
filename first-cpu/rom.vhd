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
    data : inout cpu_word
  );  
end entity;

architecture preloaded of rom is
begin
  process is
    constant high_address : natural := mem_high_addr(mem_size);

    type mem_array is
      array (natural range 0 to high_address) of cpu_word;
    variable mem : mem_array
      := (
        x"01", x"02", x"03", x"04",
        others => x"11"
      );
  begin
    loop
      data <= to_x01(mem(to_integer(unsigned(address))));
      wait until rising_edge(clk);
    end loop;
  end process;
end architecture;

architecture file_preloaded of rom is
begin
  process is
    constant high_address : natural := mem_high_addr(mem_size);

    type mem_array is
      array (natural range 0 to high_address) of cpu_word;
    variable mem : mem_array;

    procedure load is
      file binary_file : text open read_mode is load_filename;
      variable buf : line;
      variable bit_word : cpu_bit_word;

      variable addr : natural := 0;
    begin
      while not endfile(binary_file) loop
        readline(binary_file, buf);
        binary_read(buf, bit_word);

        mem(addr) := cpu_word(to_x01(bit_word));
        addr := addr + 1;
      end loop;
    end procedure;

    procedure do_read is
    begin
    end procedure;
  begin
    load;

    loop
      data <= to_x01(mem(to_integer(unsigned(address))));
      wait until rising_edge(clk);
    end loop;
  end process;
end architecture;
