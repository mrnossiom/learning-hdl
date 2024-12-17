entity nand_gate is
  port (
    a, b : in bit;
    q : out bit
  );
end entity;

architecture rtl of nand_gate is
begin
  q <= a nand b;
end architecture;

--

entity nand_gate_tb is
end entity;

architecture behavior of nand_gate_tb is
  signal a, b, q : bit;
begin
  nand_0: entity work.nand_gate
    port map(a => a, b => b, q => q);

  process
  begin
    a <= '0', '1' after 2 ns;
    b <= '0', '1' after 1 ns, '0' after 2 ns, '1' after 3 ns;
    wait for 4 ns;

    wait;
  end process;
end architecture;
