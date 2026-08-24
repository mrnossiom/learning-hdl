library ieee;
use ieee.std_logic_1164.all;

library second_cpu;
use second_cpu.types.all;

entity arbiter is
  port (
    clk, rst : in std_logic;

    memory_address : in cpu_addr;
    memory_strobe : in std_logic;
    memory_mode : in mem_mode;
    memory_ready : out std_logic;
    memory_data : inout cpu_word;

    imem_address : in cpu_addr;
    imem_strobe : in std_logic;
    imem_mode : in mem_mode;
    imem_ready : out std_logic;
    imem_data : inout cpu_word;

    dmem_address : in cpu_addr;
    dmem_strobe : in std_logic;
    dmem_mode : in mem_mode;
    dmem_ready : out std_logic;
    dmem_data : inout cpu_word
  );
end entity;

architecture rtl of arbiter is
  type arbiter_state is (IDLE, BUSY, DONE);
  signal state : arbiter_state;
begin
  process(rst, clk)
  begin
    if rst then
      state <= IDLE;
      memory_data <= (others => 'Z');
      imem_data <= (others => 'Z');
      dmem_data <= (others => 'Z');
    elsif rising_edge(clk) then
      case state is
        when IDLE =>
          -- make dmem higher precedence
          if dmem_strobe then
            state <= BUSY;
          elsif imem_strobe then
            state <= BUSY;
          end if;
        when BUSY =>
        when DONE =>
      end case;
    end if;
  end process;
end architecture;
