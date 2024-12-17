entity not_gate is
  port (
    a : in bit;
    q : out bit
  );
end entity;

architecture structural of not_gate is
begin
  nand_0: entity work.nand_gate(rtl)
    port map(
        a => a,
        b => a,
        q => q
    );
end architecture;

--

entity not_gate_tb is
end entity;

architecture behavior of not_gate_tb is
  signal a, q : bit;
begin
  not_0: entity work.not_gate(structural) port map (a => a, q => q);

  process
  begin
    a <= '0', '1' after 1 ns;
    wait for 2 ns;
    wait;
  end process;
end architecture;
