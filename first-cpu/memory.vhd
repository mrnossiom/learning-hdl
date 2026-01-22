entity rs_flip_flop is
  port (
    clk : in bit;
    reset, set : in bit;
    q, qbar : out bit
  );  
end entity;

architecture rtl of rs_flip_flop is
  signal s1, s2 : bit;
begin
  q <= (reset and clk) nor qbar;
  qbar <= (set and clk) nor q;
end architecture;
