# Verification

Each `dv/unit/*_tb.sv` testbench is self-checking and finishes with a non-zero
exit through `$fatal` on failure. Run the portable regression with
`make test-iverilog`; run the independent simulator implementation with
`make test-verilator`.

Protocol models under `rtl/model` and `rtl/verif` are compatibility utilities,
not part of the synthesis source list. New tests must not rely on a simulator
vendor library.
