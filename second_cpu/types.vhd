library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package types is
  type memory is range 0 to 1E10
    units
      b;
      kb = 1000 b;
      mb = 1000 kb;
      gb = 1000 mb;
      kib = 1024 b;
      mib = 1024 kib;
      gib = 1024 mib;
    end units;

  function nbits_address_to_memory(nbits : natural) return memory;

  function mem_high_addr(m : memory) return natural;

  ---

  constant CLK_PERIOD : time := 10 ns;
  constant HALF_CLK_PERIOD : time := CLK_PERIOD / 2;

  type cpu_state is (
    S_FETCH,
    S_FETCH_WAIT,
    S_DECODE,
    S_EXECUTE,
    S_MEMORY,
    S_WRITEBACK
  );

  subtype cpu_alu_op is std_logic_vector(3 downto 0);
  constant ALU_OP_NOP : cpu_alu_op := b"1111";
  constant ALU_OP_ADD : cpu_alu_op := b"0000";
  constant ALU_OP_SUB : cpu_alu_op := b"0001";
  constant ALU_OP_MUL : cpu_alu_op := b"0010";
  constant ALU_OP_AND : cpu_alu_op := b"0011";
  constant ALU_OP_OR  : cpu_alu_op := b"0100";
  constant ALU_OP_XOR : cpu_alu_op := b"0101";

  -- left/right shift and their carry counterparts
  constant ALU_OP_LS  : cpu_alu_op := b"1000";
  constant ALU_OP_RS  : cpu_alu_op := b"1001";
  constant ALU_OP_CLS : cpu_alu_op := b"1010";
  constant ALU_OP_CRS : cpu_alu_op := b"1011";
  -- arithmetic right shift
  constant ALU_OP_ARS : cpu_alu_op := b"1100";
  constant ALU_OP_INC : cpu_alu_op := b"1101";
  constant ALU_OP_DEC : cpu_alu_op := b"1110";

  subtype cpu_addr is std_logic_vector(7 downto 0);

  -- register number
  subtype cpu_regnum is std_logic_vector(3 downto 0);

  subtype cpu_word is std_logic_vector(7 downto 0);
  subtype cpu_bit_word is bit_vector(7 downto 0);

  subtype cpu_instr is std_logic_vector(7 downto 0);
  subtype cpu_instr_opcode is std_logic_vector(7 downto 4);

  type mem_mode is (READ, WRITE);

  -- Reg
  constant INSTR_OPCODE_ADD_RN    : cpu_instr_opcode := b"0000";
  constant INSTR_OPCODE_SUB_RN    : cpu_instr_opcode := b"0001";
  constant INSTR_OPCODE_MUL_RN    : cpu_instr_opcode := b"0010";
  constant INSTR_OPCODE_AND_RN    : cpu_instr_opcode := b"0011";
  constant INSTR_OPCODE_OR_RN     : cpu_instr_opcode := b"0100";
  constant INSTR_OPCODE_XOR_RN    : cpu_instr_opcode := b"0101";

  constant INSTR_OPCODE_CP_ACC_RN : cpu_instr_opcode := b"1000";
  constant INSTR_OPCODE_CP_RN_ACC : cpu_instr_opcode := b"1001";
  constant INSTR_OPCODE_CMP_RN    : cpu_instr_opcode := b"1010";

  -- Imm
  constant INSTR_OPCODE_BRANCH      : cpu_instr_opcode := b"1011";
  constant INSTR_OPCODE_BRANCH_COND : cpu_instr_opcode := b"1100";
  constant INSTR_OPCODE_LLI_IMM     : cpu_instr_opcode := b"1101";
  constant INSTR_OPCODE_LUI_IMM     : cpu_instr_opcode := b"1110";

  -- Custom
  constant INSTR_OPCODE_CUSTOM   : cpu_instr_opcode := b"1111";

  constant INSTR_CUSTOM_LS       : cpu_instr_opcode := b"1000";
  constant INSTR_CUSTOM_RS       : cpu_instr_opcode := b"1001";
  constant INSTR_CUSTOM_CLS      : cpu_instr_opcode := b"1010";
  constant INSTR_CUSTOM_CRS      : cpu_instr_opcode := b"1011";
  constant INSTR_CUSTOM_ARS      : cpu_instr_opcode := b"1100";
  constant INSTR_CUSTOM_INC      : cpu_instr_opcode := b"1101";
  constant INSTR_CUSTOM_DEC      : cpu_instr_opcode := b"1110";

  constant INSTR_CUSTOM_NOP      : cpu_instr_opcode := b"0000";
  constant INSTR_CUSTOM_HALT     : cpu_instr_opcode := b"0111";

  constant HIGH_ADDRESS : natural := 2 ** cpu_addr'length - 1;

  type mem_array is
    array (natural range 0 to HIGH_ADDRESS) of cpu_word;

  impure function load_memory_from_file(path : string) return mem_array;
  impure function dump_memory_to_file(path : string; mem : mem_array) return boolean;
end package;

package body types is
  function mem_high_addr(m : memory) return natural is
  begin
    return (m / 1 b) - 1;
  end function;

  function nbits_address_to_memory(nbits : natural) return memory is
  begin
    return (2 ** nbits) * 1 b;
  end function;

  type raw_file is file of character;

  impure function load_memory_from_file(path : string) return mem_array is
    variable status : file_open_status;
    file dump_file : raw_file;

    variable chr : character;
    variable mem : mem_array := (others => x"00");
    variable addr : natural := 0;
  begin
    file_open(status, dump_file, path, READ_MODE);
    assert status = open_ok
      report "could not open memory file: " & path
      severity error;

    while not endfile(dump_file) loop
      read(dump_file, chr);
      mem(addr) := cpu_word(to_unsigned(character'pos(chr), 8));
      addr := addr + 1;
    end loop;
    return mem;
  end function;

  impure function dump_memory_to_file(path : string; mem : mem_array) return boolean is
    variable status : file_open_status;
    file dump_file : raw_file;

    variable chr : character;
  begin
    file_open(status, dump_file, path, WRITE_MODE);
    assert status = open_ok
      report "could not open memory file: " & path
      severity error;

    for addr in mem'range loop
      chr := character'val(to_integer(unsigned(mem(addr))));
      write(dump_file, chr);
    end loop;

    return true;
  end function;
end package body;
