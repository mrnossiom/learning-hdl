library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library first_cpu;
use first_cpu.types.all;

entity control_unit is
  port (
    reset : in std_logic;
    instr : in cpu_word;

    alu_carry : in std_logic;

    pc : in cpu_addr;
    next_pc : out cpu_addr;

    data_bus : inout cpu_word;

    alu_op : out cpu_alu_op;

    reg_read_en : out std_logic;
    reg_read_num : out cpu_regnum;
    reg_write_en : out std_logic;
    reg_write_num : out cpu_regnum;
    acc_sel_alu : out std_logic;
    acc_write_en : out std_logic;
    acc_read_en : out std_logic;
    carry_write_en : out std_logic
  );
begin
end entity;

architecture rtl of control_unit is
  alias opcode is instr(7 downto 4);

  alias reg_rn is instr(3 downto 0);
  alias imm_imm4 is instr(3 downto 0);
  alias custom_content is instr(3 downto 0);
begin
  process(all)
  begin
    -- reset r/w flags
    alu_op <= ALU_OP_NOP;
    acc_read_en <= '0';
    acc_write_en <= '0';
    acc_sel_alu <= '0';
    reg_read_en <= '0';
    reg_write_en <= '0';
    carry_write_en <= '0';
    data_bus <= (others => 'Z');

    if reset = '1' then
      next_pc <= (others => '0');
    else
      next_pc <= cpu_addr(to_01(unsigned(pc) + 1));

      case opcode is
        -- Reg
        when INSTR_OPCODE_ADD_RN =>
          report "executing `add r" & to_string(to_integer(unsigned(reg_rn))) & "`" severity note;
          alu_op <= ALU_OP_ADD;
          reg_read_en <= '1';
          reg_read_num <= reg_rn;
          acc_sel_alu <= '1';
          acc_write_en <= '1';
          carry_write_en <= '1';
        when INSTR_OPCODE_SUB_RN =>
          report "executing `sub r" & to_string(to_integer(unsigned(reg_rn))) & "`" severity note;
          alu_op <= ALU_OP_SUB;
          reg_read_en <= '1';
          reg_read_num <= reg_rn;
          acc_sel_alu <= '1';
          acc_write_en <= '1';
          carry_write_en <= '1';
        when INSTR_OPCODE_MUL_RN =>
          report "`mul rn` not yet implemented" severity failure;
          report "executing `mul r" & to_string(to_integer(unsigned(reg_rn))) & "`" severity note;
        when INSTR_OPCODE_AND_RN =>
          report "executing `and r" & to_string(to_integer(unsigned(reg_rn))) & "`" severity note;
          alu_op <= ALU_OP_AND;
          acc_sel_alu <= '1';
          reg_read_en <= '1';
          reg_read_num <= reg_rn;
          acc_write_en <= '1';
          carry_write_en <= '1';
        when INSTR_OPCODE_OR_RN =>
          report "executing `or r" & to_string(to_integer(unsigned(reg_rn))) & "`" severity note;
          alu_op <= ALU_OP_OR;
          acc_sel_alu <= '1';
          reg_read_en <= '1';
          reg_read_num <= reg_rn;
          acc_write_en <= '1';
          carry_write_en <= '1';
        when INSTR_OPCODE_XOR_RN =>
          report "executing `xor r" & to_string(to_integer(unsigned(reg_rn))) & "`" severity note;
          alu_op <= ALU_OP_XOR;
          acc_sel_alu <= '1';
          reg_read_en <= '1';
          reg_read_num <= reg_rn;
          acc_write_en <= '1';
          carry_write_en <= '1';
        when INSTR_OPCODE_CP_ACC_RN =>
          report "executing `cp acc,r" & to_string(to_integer(unsigned(reg_rn))) & "`" severity note;
          -- write acc value to the bus
          acc_read_en <= '1';
          -- write the bus to rn
          reg_write_en <= '1';
          reg_write_num <= reg_rn;
        when INSTR_OPCODE_CP_RN_ACC =>
          report "executing `cp r" & to_string(to_integer(unsigned(reg_rn))) & ",acc`" severity note;
          -- write rn value to the bus
          reg_read_en <= '1';
          reg_read_num <= reg_rn;
          -- write the bus to acc, reading from the bus
          acc_write_en <= '1';
          acc_sel_alu <= '0';
        when INSTR_OPCODE_CMP_RN =>
          report "executing `cmp r" & to_string(to_integer(unsigned(reg_rn))) & "`" severity note;
          -- do a sub instr
          alu_op <= ALU_OP_SUB;
          acc_sel_alu <= '1';
          reg_read_en <= '1';
          reg_read_num <= reg_rn;
          -- do not write result to acc, just keep carry
          carry_write_en <= '1';

        -- Imm
        when INSTR_OPCODE_BRANCH =>
          report "executing `b " & to_string(imm_imm4) & "`" severity note;
          -- todo smarter jumps with multiples of 2 or 4
          next_pc <= b"0000" & imm_imm4;
        when INSTR_OPCODE_BRANCH_COND =>
          report "executing `bc " & to_string(imm_imm4) & "`" severity note;
          if alu_carry then
            next_pc <= b"0000" & imm_imm4;
          end if;
        when INSTR_OPCODE_LLI_IMM =>
          report "executing `lli " & to_string(imm_imm4) & "`" severity note;
          data_bus <= "0000" & imm_imm4;
          acc_write_en <= '1';
          acc_sel_alu <= '0';
        when INSTR_OPCODE_LUI_IMM =>
          report "executing `lui " & to_string(imm_imm4) & "`" severity note;
          -- todo find a way to load full 8bit constants without erasing bottom
          data_bus <= imm_imm4 & "0000";
          acc_write_en <= '1';
          acc_sel_alu <= '0';

        -- Custom
        when INSTR_OPCODE_CUSTOM =>
          case custom_content is
            when INSTR_CUSTOM_LS =>
              report "executing `ls`" severity note;
              alu_op <= ALU_OP_LS;
              acc_sel_alu <= '1';
              acc_write_en <= '1';
            when INSTR_CUSTOM_RS =>
              report "executing `rs`" severity failure;
            when INSTR_CUSTOM_CLS =>
              report "executing `cls`" severity failure;
            when INSTR_CUSTOM_CRS =>
              report "executing `crs`" severity failure;
            when INSTR_CUSTOM_ASR =>
              report "executing `asr`" severity failure;

            when INSTR_CUSTOM_INC =>
              report "executing `inc`" severity note;
              alu_op <= ALU_OP_ADD;
              data_bus <= x"01";
              acc_sel_alu <= '1';
              acc_write_en <= '1';
              carry_write_en <= '1';
            when INSTR_CUSTOM_DEC =>
              report "executing `dec`" severity note;
              alu_op <= ALU_OP_SUB;
              data_bus <= x"01";
              acc_sel_alu <= '1';
              acc_write_en <= '1';
              carry_write_en <= '1';

            when INSTR_CUSTOM_NOP =>
              report "executing `nop`" severity note;
              -- actively do nothing
            when INSTR_CUSTOM_HALT =>
              report "executing `halt`" severity note;
              next_pc <= pc;
            when others =>
              report "illegal custom instruction " & to_string(custom_content) severity failure;
          end case;
        when others =>
          report "illegal instruction " & to_string(instr) severity failure;
      end case;
    end if;
  end process;
end architecture;
