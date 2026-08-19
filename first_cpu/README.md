# Simple CPU

# ISA

## Version 1

0-bit CPU (no IO) with 8-bit ISA.

### Format

```
Type       7        4 3        0
          ┌──────────┬──────────┐
Reg       │ Opcode   │ Rn       │
          ├──────────┼──────────┤
Imm       │ Opcode   │ Imm4     │
          ├──────────┼──────────┤
Custom    │ Opcode   │ undef    │
          └──────────┴──────────┘
```

### Instructions

```
nop         0000 0000 ; does nothing

add rn      0100 0rrr ; acc, carry <= acc + rn
sub rn      0100 1rrr ; acc, carry <= acc - rn
mul rn      0101 0rrr
and rn      0101 1rrr
or  rn      0110 0rrr
xor rn      0110 1rrr

ls          1111 1000 ; left shift, zero-extends
rs          1111 1001 ; right shift, zero-extends
cls         1111 1010 ; circular left shift
crs         1111 1011 ; circular right shift
ars         1111 1100 ; arithmetic right shift, sign-extends

inc         1111 1101 ; increment acc
dec         1111 1110 ; decrement acc

ld acc,rn   0111 0rrr ; load
st rn,acc   0111 1rrr ; store

cp acc,rn   1000 0rrr ; copies acc to rn
cp rn,acc   1001 0rrr ; copies rn to acc

cmp rn      1010 0rrr ; carry <= acc - rn

b label     1011 iiii
bc label    1100 iiii ; branch conditional, branch if carry/borrow is 1

lli imm4    1101 iiii ; load lower immediate
lui imm4    1110 iiii ; load upper immediate


halt        1111 0111 ; stops the cpu
```

# Resources

- Ashenden (1996) The designer’s guide to VHDL. Morgan Kaufmann.
- https://devansh-lodha.github.io/blog/posts/processor_verilog/processor_verilog.html
- https://domipheus.com/blog/rpu-series-quick-links/
- https://wavedrom.com/editor.html
