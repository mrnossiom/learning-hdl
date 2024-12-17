entity or_gate is
  port (
    a, b : in bit;
    q : out bit
  );
end entity;

architecture structural of or_gate is
  signal na, nb : bit;
begin
  not_0: entity work.not_gate(structural) port map (a => a, q => na);
  not_1: entity work.not_gate(structural) port map (a => b, q => nb);

  nand_0: entity work.nand_gate(rtl) port map (a => na, b => nb, q => q);
end structural;

--

entity or_gate_tb is
end entity;

architecture behavior of or_gate_tb is
  signal a, b, q : bit;
begin
  or_0: entity work.or_gate(structural) port map (a => a, b => b, q => q);

  process is
  begin
    a <= '0', '1' after 2 ns;
    b <= '0', '1' after 1 ns, '0' after 2 ns, '1' after 3 ns;
    wait for 4 ns;

    wait;
  end process;
end architecture;
