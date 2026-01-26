library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

entity cpu is
  port (
    clk, reset : in std_logic := '0'
  );
end entity;

architecture rtl of cpu is
  signal pc : cpu_addr := x"00";
  signal next_pc : cpu_addr := x"00";
  signal bus_io : cpu_word;
  signal alu_op : cpu_alu_op;

  signal instr : cpu_word;

  signal reg_read_en, reg_write_en : std_logic;
  signal reg_read_num, reg_write_num : cpu_rn;
  signal acc_sel_alu : std_logic;
  signal acc_write_en, acc_output_en : std_logic;
  signal carry_write_en : std_logic;

  signal alu_carry : std_logic;
  signal carry_reg : std_logic;
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
      bus_io => bus_io
  );

  instrs_rom: entity work.rom(file_preloaded)
    generic map(
      mem_size => 1 mb,
      load_filename => "program.bin"
    )
    port map(
      address => pc,
      data => instr
    );

  control_unit: entity work.control_unit
    port map(
      instr => instr,
      carry_reg => carry_reg,
      alu_carry => alu_carry,
      pc => pc,
      bus_io => bus_io,
      alu_op => alu_op,
      next_pc => next_pc,
      reg_read_en => reg_read_en,
      reg_read_num => reg_read_num,
      reg_write_en => reg_write_en,
      reg_write_num => reg_write_num,
      acc_sel_alu => acc_sel_alu,
      acc_write_en => acc_write_en,
      acc_output_en => acc_output_en,
      carry_write_en => carry_write_en
    );

  accumulator: entity work.accumulator
    port map(
      clk => clk,
      output_en => acc_output_en,
      write_en => acc_write_en,
      sel_alu => acc_sel_alu,
      alu_in => alu_result,
      bus_io => bus_io,
      acc => acc
    );

  alu: entity work.alu
    port map(
      acc => acc,
      bus_in => bus_io,
      alu_op => alu_op,
      result => alu_result,
      alu_carry => alu_carry,
      extended_result => extd_result
    );

  process(clk)
  begin
    if falling_edge(clk) then
      pc <= x"00" when reset else next_pc;
    end if;
  end process;
end;
