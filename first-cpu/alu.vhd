library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.custom_cpu_types.all;

entity alu is
  port (
    acc : in std_logic_vector(7 downto 0);
    bus_in : in std_logic_vector(7 downto 0);
    alu_op : in std_logic_vector(3 downto 0);

    result : out std_logic_vector(7 downto 0);
    alu_carry : out std_logic;
    ext_result : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of alu is
begin
  process(all)
    variable res_9bit : unsigned(8 downto 0);
    variable res_16bit : unsigned(15 downto 0);
  begin
    result <= acc;
    alu_carry <= '0';
    ext_result <= (others => '0');

    case to_alu_op(alu_op) is
      when OP_ADD =>
        res_9bit := unsigned('0' & acc) + unsigned('0' & bus_in);
        result <= std_logic_vector(res_9bit(7 downto 0));
        alu_carry <= res_9bit(8);
      when OP_SUB =>
        res_9bit := unsigned('0' & acc) - unsigned('0' & bus_in);
        result <= std_logic_vector(res_9bit(7 downto 0));
        alu_carry <= res_9bit(8);
      when OP_MUL =>
        res_16bit := unsigned(acc) * unsigned(bus_in);
        result <= std_logic_vector(res_16bit(7 downto 0));
        ext_result <= std_logic_vector(res_16bit(15 downto 7));

      when OP_AND => result <= acc and bus_in;
      when OP_XOR => result <= acc xor bus_in;
      when OP_LS => result <= acc(6 downto 0) & '0';
      when OP_RS => result <= '0' & acc(7 downto 1);
      when OP_CLS => result <= acc(6 downto 0) & acc(7);
      when OP_CRS => result <= acc(0) & acc(7 downto 1);
      when OP_ASR => result <= acc(7) & acc(7 downto 1);

      when OP_INC =>
        res_9bit := unsigned('0' & acc) + 1;
        result <= std_logic_vector(res_9bit(7 downto 0));
        alu_carry <= res_9bit(8);
      when OP_DEC =>
        res_9bit := unsigned('0' & acc) - 1;
        result <= std_logic_vector(res_9bit(7 downto 0));
        alu_carry <= res_9bit(8);

      when OP_UNKNOWN =>
        -- TODO: crash
    end case;
  end process;
end architecture;
