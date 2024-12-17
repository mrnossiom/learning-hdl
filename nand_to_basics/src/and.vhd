entity and_gate is
  port (
    a, b : in bit;
    q : out bit
  );
end entity;

architecture structural of and_gate is
  signal nd : bit;
begin
  nand_0: entity work.nand_gate(rtl)
    port map(
      a => a,
      b => b,
      q => nd
    );

  not_0: entity work.not_gate(structural)
    port map(
      a => nd,
      q => q
    );
end architecture;

--

entity and_gate_tb is
end entity;

architecture behavior of and_gate_tb is
  signal a, b, q : bit;
begin
  and_0: entity work.and_gate(structural)
    port map(
        a => a,
        b => b,
        q => q
    );

  process
  begin
    a <= '0', '1' after 2 ns;
    b <= '0', '1' after 1 ns, '0' after 2 ns, '1' after 3 ns;
    wait for 4 ns;

    wait;
  end process;
end architecture;
