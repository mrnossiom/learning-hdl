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
- Reg
add rn      0000        rn ; acc, carry <= acc + rn
sub rn      0001        rn ; acc, carry <= acc - rn
mul rn      0010        rn
and rn      0011        rn
or  rn      0100        rn
xor rn      0101        rn
            0110        rn ; reserved
            0111        rn ; reserved

cp acc,rn   1000        rn ; copies acc to rn
cp rn,acc   1001        rn ; copies rn to acc

cmp rn      1010        rn ; carry <= acc - rn

- Imm
b label     1011        imm4
bc label    1100        imm4 ; branch conditional, branch if carry/borrow is 1

lli imm4    1101        imm4 ; load lower immediate
lui imm4    1110        imm4 ; load upper immediate

- Custom
ls          1111        1000 ; left shift, zero-extends
rs          1111        1001 ; right shift, zero-extends
cls         1111        1010 ; circular left shift
crs         1111        1011 ; circular right shift
ars         1111        1100 ; arithmetic right shift, sign-extends

inc         1111        1101 ; increment acc
dec         1111        1110 ; decrement acc

nop         1111        0000 ; does nothing
halt        1111        0111 ; stops the cpu
```

# Resources

- Ashenden (1996) The designer’s guide to VHDL. Morgan Kaufmann.
- https://devansh-lodha.github.io/blog/posts/processor_verilog/processor_verilog.html
- https://domipheus.com/blog/rpu-series-quick-links/
- https://wavedrom.com/editor.html
