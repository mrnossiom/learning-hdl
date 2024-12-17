entity demux is
  port (
    a : in bit;
    -- 0 is q, 1 is r
    s : in bit;
    q, r : out bit
  );
end entity;

architecture structural of demux is
  signal ns : bit;
begin
  not_0: entity work.not_gate(structural)
    port map(a => s, q => ns);

  and_q: entity work.and_gate(structural)
   port map(a => a, b => ns, q => q);
  and_r: entity work.and_gate(structural)
   port map(a => a, b => s, q => r);
end architecture;

architecture rtl of demux is
begin
  q <= a and (not s);
  r <= a and s;
end architecture;

--

entity demux_gate_tb is
end entity;

architecture behavior of demux_gate_tb is
  signal a, s, q, r : bit;
begin
  demux_0: entity work.demux(rtl) port map (a => a, s => s, q => q, r => r);

  process is
  begin
    s <= '0', '1' after 2 ns;

    a <= '0', '1' after 1 ns, '0' after 2 ns, '1' after 3 ns;
    wait for 4 ns;

    wait;
  end process;
end architecture;
