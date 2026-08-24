library ieee;
use ieee.std_logic_1164.all;

library second_cpu;
use second_cpu.types.all;

entity cpu is
  port (
    clk, rst : in std_logic;

    memory_address : out cpu_addr;
    memory_strobe : out std_logic;
    memory_mode : out mem_mode;
    memory_ready : in std_logic;
    memory_data : inout cpu_word
  );
end entity;

architecture rtl of cpu is
  signal state : cpu_state := S_FETCH;

  signal fetch_ready : std_logic;
  signal fetch_instruction : cpu_word;

  signal pc : cpu_addr := (others => '0');
  signal next_pc : cpu_addr;

  signal data_bus : cpu_word;
  signal alu_op : cpu_alu_op;

  signal reg_read_en, reg_write_en : std_logic;
  signal reg_read_num, reg_write_num : cpu_regnum;
  signal acc_sel_alu : std_logic;
  signal acc_write_en, acc_read_en : std_logic;
  signal carry_write_en : std_logic;

  signal alu_carry : std_logic := '0';
  signal alu_carry_next : std_logic;
  signal extd_result : cpu_word;

  signal alu_result, acc : cpu_word;
begin
  fetch_unit: entity second_cpu.cpu_fetch
    port map(
      clk => clk,
      rst => rst,
      state => state,
      pc => pc,
      mem_address => memory_address,
      mem_strobe => memory_strobe,
      mem_mode => memory_mode,
      mem_ready => memory_ready,
      mem_data => memory_data,
      ready => fetch_ready,
      instruction => fetch_instruction
    );

  control_unit: entity second_cpu.cpu_control
    port map(
      clk => clk,
      rst => rst,
      state => state,
      instr => fetch_instruction,
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

  regfile_unit: entity second_cpu.cpu_regfile
    port map(
      clk => clk,
      read_en => reg_read_en,
      write_en => reg_write_en,
      read_num => reg_read_num,
      write_num => reg_write_num,
      data_bus => data_bus
  );

  acc_unit: entity second_cpu.cpu_acc
    port map(
      clk => clk,
      read_en => acc_read_en,
      write_en => acc_write_en,
      sel_alu => acc_sel_alu,
      alu_in => alu_result,
      data_bus => data_bus,
      acc => acc
    );

  alu_unit: entity second_cpu.cpu_alu
    port map(
      clk => clk,
      rst => rst,
      acc => acc,
      data_bus => data_bus,
      alu_op => alu_op,
      result => alu_result,
      alu_carry => alu_carry_next,
      extended_result => extd_result
    );

  process(rst, clk)
  begin
    if rst then
      pc <= (others => '0');
      alu_carry <= '0';
      state <= S_FETCH;
    elsif rising_edge(clk) then
      pc <= next_pc;
      alu_carry <= alu_carry_next when carry_write_en else alu_carry;

      case state is
        when S_FETCH =>
          -- state passed to the fetch unit, triggers fetch
          state <= S_FETCH_WAIT;
        when S_FETCH_WAIT =>
          if fetch_ready then
            state <= S_DECODE;
          end if;
        when S_DECODE =>
          state <= S_EXECUTE;
        when S_EXECUTE =>
          state <= S_MEMORY;
        when S_MEMORY =>
          -- if load then wb else fetch
          state <= S_FETCH;
        when S_WRITEBACK =>
          state <= S_FETCH;
      end case;
    end if;
  end process;
end;
