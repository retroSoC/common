# RTL Delivery Datasheet

The public source order is `flist/rtl.f`. Components use SystemVerilog-2012
and are verified with Icarus Verilog and Verilator. The portable behavioral
storage models are for simulation, FPGA prototyping, and generic synthesis;
ASIC projects must replace `tech_*` models through their technology flow.

The source list additionally contains the self-contained base replacement and
SECDED cells, stream-control cells, and warm-flush CDC wrappers. They depend
only on RTL files in this repository. The SECDED package is ordered before its
encoder and decoder, and warm-flush wrappers are ordered after their existing
CDC/reset primitives.

Clock and CDC cells have explicit integration restrictions in
`docs/design.md`. They are not substitutes for STA constraints, reset-domain
analysis, or physical CDC signoff.
