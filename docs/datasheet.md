# RTL Delivery Datasheet

The public source order is `flist/rtl.f`. Components use SystemVerilog-2012
and are verified with Icarus Verilog and Verilator. The portable behavioral
storage models are for simulation, FPGA prototyping, and generic synthesis;
ASIC projects must replace `tech_*` models through their technology flow.

Clock and CDC cells have explicit integration restrictions in
`docs/design.md`. They are not substitutes for STA constraints, reset-domain
analysis, or physical CDC signoff.
