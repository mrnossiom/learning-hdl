library ieee;
use ieee.std_logic_1164.all;

library second_cpu;
use second_cpu.types.all;

entity chip is
  generic (
    memory_file : string
  );
  port (
    clk, rst : in std_logic;

    dbg_mem : out mem_array
  );
end chip;

architecture rtl of chip is
  signal memory_address : cpu_addr;
  signal memory_strobe : std_logic;
  signal memory_mode : mem_mode;
  signal memory_ready : std_logic;
  signal memory_data : cpu_word;
begin
  cpu: entity second_cpu.cpu
    port map(
      clk => clk,
      rst => rst,
      memory_address => memory_address,
      memory_data => memory_data,
      memory_strobe => memory_strobe,
      memory_mode => memory_mode,
      memory_ready => memory_ready
    );

  memory: entity second_cpu.ram(file_preloaded)
    generic map(
      memory_file => memory_file
    )
    port map(
      clk => clk,
      rst => rst,
      address => memory_address,
      strobe => memory_strobe,
      mode => memory_mode,
      ready => memory_ready,
      data => memory_data,
      dbg_mem => dbg_mem
    );

end architecture;
