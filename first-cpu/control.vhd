use work.types.all;

entity control_unit is
  port (
    clk, reset : in bit;
    instr : in cpu_word;
    cb_reg : in bit;
    alu_carry : in bit;
    current_pc : in cpu_addr;
    bus_in : in cpu_word;
    
    alu_op_out : out alu_op;
    next_pc : out alu_op
  );
begin
end entity;

architecture rtl of control_unit is
  alias opcode is instr(7 downto 4);

  alias reg_rn is instr(3 downto 0);
  alias imm_imm4 is instr(3 downto 0);
  alias custom_content is instr(3 downto 0);
begin
  process(clk)
  begin
    case opcode is
      -- Reg
      when instr_opcode_alu_rn => 
        alu_op_out(3) <= '0';
        alu_op_out(2 downto 0) <= opcode(2 downto 1);
      when instr_opcode_cp_acc_rn => 
      when instr_opcode_cp_rn_acc => 
      when instr_opcode_cmp_rn => 

      -- Imm
      when instr_opcode_branch => 
        next_pc <= imm_imm4;
      when instr_opcode_beq => 
        if cb_reg then
          next_pc <= imm_imm4;
        end if;
      when instr_opcode_lli_imm => 
      when instr_opcode_lui_imm => 

      -- Custom
      when instr_opcode_custom => 
        case custom_content is
          when instr_custom_alu =>
            alu_op_out(3) <= '1';
            alu_op_out(2 downto 0) <= custom_content(2 downto 1);
          when instr_custom_nop =>
            -- do nothing
          when instr_custom_halt =>
            next_pc <= current_pc;
          when others =>
            report "illegal custom instruction" severity failure;
        end case;

      when others =>
        report "illegal instruction" severity failure;
        wait;
    end case;
  end process;
end architecture;
