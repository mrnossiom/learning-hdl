# Simple CPU

# ISA

## Version 1

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
add rn      0000        rn
sub rn      0001        rn
mul rn      0010        rn
and rn      0011        rn
or  rn      0100        rn
xor rn      0101        rn
reserved    0110        rn
reserved    0111        rn

cp acc,rn   1000        rn
cp rn,acc   1001        rn

cmp rn      1010        rn

- Imm
b label     1011        imm4
beq label   1100        imm4

lli imm4    1101        imm4
lui imm4    1110        imm4

- Custom
ls          1111        1000
rs          1111        1001
cls         1111        1010
crs         1111        1011
asr         1111        1100

inc         1111        1101
dec         1111        1110

nop         1111        0000
halt        1111        0111
```

# Resources

- Ashenden (1996) The designer’s guide to VHDL. Morgan Kaufmann.
- https://devansh-lodha.github.io/blog/posts/processor_verilog/processor_verilog.html
