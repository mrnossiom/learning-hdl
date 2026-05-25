library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library first_cpu;
use first_cpu.types.all;

entity alu is
  port (
    reset : in std_logic;

    alu_op : in cpu_alu_op;
    acc : in cpu_word;
    data_bus : in cpu_word;

    result : out cpu_word;
    alu_carry : out std_logic;
    extended_result : out cpu_word
  );
end entity;

architecture rtl of alu is
begin
  process(all)
    variable res_9bit : unsigned(8 downto 0);
    variable res_16bit : unsigned(15 downto 0);
  begin
    if reset then
      result <= (others => '0');
      alu_carry <= '0';
      extended_result <= (others => '0');
    else
      result <= acc;
      alu_carry <= '0';
      extended_result <= (others => '0');

      case alu_op is
        when ALU_OP_ADD =>
          res_9bit := unsigned('0' & acc) + unsigned('0' & data_bus);
          result <= cpu_word(res_9bit(7 downto 0));
          alu_carry <= res_9bit(8);
        when ALU_OP_SUB =>
          res_9bit := unsigned('0' & acc) - unsigned('0' & data_bus);
          result <= cpu_word(res_9bit(7 downto 0));
          alu_carry <= res_9bit(8);
        when ALU_OP_MUL =>
          res_16bit := unsigned(acc) * unsigned(data_bus);
          result <= cpu_word(res_16bit(7 downto 0));
          extended_result <= cpu_word(res_16bit(15 downto 8));

        when ALU_OP_AND => result <= acc and data_bus;
        when ALU_OP_XOR => result <= acc xor data_bus;
        when ALU_OP_LS => result <= acc(6 downto 0) & '0';
        when ALU_OP_RS => result <= '0' & acc(7 downto 1);
        when ALU_OP_CLS => result <= acc(6 downto 0) & acc(7);
        when ALU_OP_CRS => result <= acc(0) & acc(7 downto 1);
        when ALU_OP_ASR => result <= acc(7) & acc(7 downto 1);

        when ALU_OP_INC =>
          res_9bit := unsigned('0' & acc) + 1;
          result <= cpu_word(res_9bit(7 downto 0));
          alu_carry <= res_9bit(8);
        when ALU_OP_DEC =>
          res_9bit := unsigned('0' & acc) - 1;
          result <= cpu_word(res_9bit(7 downto 0));
          alu_carry <= res_9bit(8);

        when ALU_OP_NOP =>
          -- do nothing

        when others =>
          report "illegal alu operation " & to_string(alu_op) severity failure;
      end case;
    end if;
  end process;
end architecture;
