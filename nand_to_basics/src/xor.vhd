entity xor_gate is
  port (
    a, b : in bit;
    q : out bit
  );
end entity;

architecture structural of xor_gate is
  signal c, d : bit;
begin
  or_0: entity work.or_gate(structural)
    port map(a => a, b => b, q => c);
  nand_0: entity work.nand_gate(rtl)
    port map(a => a, b => b, q => d);

  and_0: entity work.and_gate(structural)
    port map(a => c, b => d, q => q);
end structural;

--

entity xor_gate_tb is
end entity;

architecture behavior of xor_gate_tb is
  signal a, b, q : bit;
begin
  xor_0: entity work.xor_gate(structural) port map (a => a, b => b, q => q);

  process is
  begin
    a <= '0', '1' after 2 ns;
    b <= '0', '1' after 1 ns, '0' after 2 ns, '1' after 3 ns;
    wait for 4 ns;

    wait;
  end process;
end architecture;
