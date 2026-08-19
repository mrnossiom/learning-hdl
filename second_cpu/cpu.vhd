library ieee;
use ieee.std_logic_1164.all;

library second_cpu;
use second_cpu.types.all;

entity cpu is
  port (
    clk, rst : in std_logic;

    dbg_mem : out mem_array
  );
end entity;

architecture rtl of cpu is
  signal state : cpu_state := S_FETCH;

  signal mem_address : cpu_addr;
  signal mem_data : cpu_word;
  signal mem_strobe : std_logic;
  signal mem_mode : second_cpu.types.mem_mode;
  signal mem_ready : std_logic;

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
  ram: entity second_cpu.ram(file_preloaded)
    generic map(
      load_filename => "ram.bin"
    )
    port map(
      clk => clk,
      rst => rst,

      address => mem_address,
      strobe => mem_strobe,
      mode => mem_mode,

      data => mem_data,
      ready => mem_ready,

      dbg_mem => dbg_mem
    );

  fetch: entity second_cpu.fetch
    port map(
      clk => clk,
      rst => rst,
      state => state,
      pc => pc,
      mem_address => mem_address,
      mem_data => mem_data,
      mem_strobe => mem_strobe,
      mem_ready => mem_ready,
      ready => fetch_ready,
      instruction => fetch_instruction
    );

  control_unit: entity second_cpu.control
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

  regfile: entity second_cpu.regfile
    port map(
      clk => clk,
      read_en => reg_read_en,
      write_en => reg_write_en,
      read_num => reg_read_num,
      write_num => reg_write_num,
      data_bus => data_bus
  );

  accumulator: entity second_cpu.accumulator
    port map(
      clk => clk,
      read_en => acc_read_en,
      write_en => acc_write_en,
      sel_alu => acc_sel_alu,
      alu_in => alu_result,
      data_bus => data_bus,
      acc => acc
    );

  alu: entity second_cpu.alu
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
