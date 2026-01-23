# nand to basics

# Usage

These have been used in a `fish` shell. `name` refers to a filename whereas `entity_name` refers to a real vhdl entity.

```fish
# analyse/load all file
ghdl analyze src/*.vhdl

# elaborate a design, then run
ghdl elab-run entity_name

# export a wavefile
ghdl elab-run entity_name --vcd=name.vcf
gtkwave name.vcd

# use yosys to analyze component
yosys -m ghdl -p 'ghdl src/name.vhd -e entity_name; write_json entity_name.netlist.json'
netlistsvg entity_name.netlist.json -o entity_name.svg
```

# Projects

It is possible to create all logic circuits from nand gates.

This project contain code for the following gates:

- Basics

  - Basic gates (nand composition)

    - `not_gate`
    - `and_gate`
    - `or_gate`
    - `xor_gate`
    - `mux`
    - `demux`

  - 16 bits counterparts

    - `not_16`
    - `and_16`
    - `or_16`
    - `mux_16`

  - multiple way versions

    - `or_8way`
    - `demux_4way`
    - `demux_8way`
    - `mux_4way_16`
    - `mux_8way_16`

- Basic arithmetic components

  - `half_adder`
  - `full_adder`
  - `add_16`
  - `inc_16`
  - `alu`

- Basic memory components

  - `bit`
  - `register`
  - `pc`

  - `ram_8`
  - `ram_64`
  - `ram_512`
  - `ram_4k`
  - `ram_16k`

- Final assembly

  - `cpu`
  - `memory`
  - `computer`

# Ressources

- https://fpgatutorial.com
- http://ghdl.free.fr/site/uploads/Main/ghdl_user_guide/AA_ghdl_guide.html
- https://vhdlwhiz.com
- https://www.nand2tetris.org
