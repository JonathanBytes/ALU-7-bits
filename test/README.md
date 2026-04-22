# ALU7 Serial testbench

This testbench uses [cocotb](https://docs.cocotb.org/en/stable/) to verify the
`tt_um_jonathanbytes_alu7_serial` design with Icarus Verilog.

## How to run

Run RTL simulation:

```sh
make -B
```

Run gate-level simulation (after copying the hardened netlist to `gate_level_netlist.v`):

```sh
make -B GATES=yes
```

Generate VCD instead of FST:

```sh
make -B FST=
```

View waveforms with GTKWave:

```sh
gtkwave tb.fst tb.gtkw
```
