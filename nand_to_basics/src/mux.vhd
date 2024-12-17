entity mux is
  port (
    a, b : in bit;
    -- 0 is a, 1 is b
    s : in bit;
    q : out bit
  );
end entity;

architecture structural of mux is
  signal ns : bit;
  -- filtered a and b
  signal fa, fb : bit;
begin
  not_0: entity work.not_gate(structural) port map (a => s, q => ns);

  a_filter: entity work.and_gate(structural)
    port map(a => a, b => ns, q => fa);
  b_filter: entity work.and_gate(structural)
    port map(a => b, b => s, q => fb);

  or_0: entity work.or_gate(structural)
    port map(a => fa, b => fb, q => q);
end architecture;

architecture rtl of mux is
begin
  q <= (a and (not s)) or (b and s);
end architecture;

--

entity mux_gate_tb is
end entity;

architecture behavior of mux_gate_tb is
  signal a, b, s, q : bit;
begin
  mux_0: entity work.mux(rtl) port map (a => a, b => b, s => s, q => q);

  process is
  begin
    s <= '0', '1' after 4 ns;

    a <= '0', '1' after 2 ns, '0' after 4 ns, '1' after 6 ns;
    b <= '0', '1' after 1 ns, '0' after 2 ns, '1' after 3 ns,
        '0' after 4 ns, '1' after 5 ns, '0' after 6 ns, '1' after 7 ns;
    wait for 8 ns;

    wait;
  end process;
end architecture;
