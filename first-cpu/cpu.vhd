library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

entity cpu is
  port (
    clk, reset : in std_logic
  );
end entity;

architecture rtl of cpu is
  signal pc : cpu_addr := (others => '0');
  signal next_pc : cpu_addr;
  signal data_bus : cpu_word;
  signal alu_op : cpu_alu_op;

  signal instr : cpu_word;

  signal reg_read_en, reg_write_en : std_logic;
  signal reg_read_num, reg_write_num : cpu_regnum;
  signal acc_sel_alu : std_logic;
  signal acc_write_en, acc_read_en : std_logic;
  signal carry_write_en : std_logic;

  signal alu_carry : std_logic;
  signal extd_result : cpu_word;

  signal alu_result, acc : cpu_word;
begin
  regfile: entity work.regfile
    port map(
      clk => clk,
      read_en => reg_read_en,
      write_en => reg_write_en,
      read_num => reg_read_num,
      write_num => reg_write_num,
      data_bus => data_bus
  );

  instructions_rom: entity work.rom(file_preloaded)
    generic map(
      mem_size => 1 kb,
      load_filename => "program.bin"
    )
    port map(
      clk => clk,
      address => next_pc,
      instr => instr
    );

  control_unit: entity work.control_unit
    port map(
      reset => reset,
      instr => instr,
      alu_carry => alu_carry,
      pc => pc,
      data_bus => data_bus,
      alu_op => alu_op,
      next_pc => next_pc,
      reg_read_en => reg_read_en,
      reg_read_num => reg_read_num,
      reg_write_en => reg_write_en,
      reg_write_num => reg_write_num,
      acc_sel_alu => acc_sel_alu,
      acc_write_en => acc_write_en,
      acc_read_en => acc_read_en,
      carry_write_en => carry_write_en
    );

  accumulator: entity work.accumulator
    port map(
      clk => clk,
      read_en => acc_read_en,
      write_en => acc_write_en,
      sel_alu => acc_sel_alu,
      alu_in => alu_result,
      data_bus => data_bus,
      acc => acc
    );

  alu: entity work.alu
    port map(
      clk => clk,
      acc => acc,
      data_bus => data_bus,
      alu_op => alu_op,
      result => alu_result,
      alu_carry => alu_carry,
      extended_result => extd_result
    );

  process(clk)
  begin
    if rising_edge(clk) then
      if reset then
        pc <= (others => '0');
      else
        pc <= next_pc;
      end if;
    end if;
  end process;
end;
