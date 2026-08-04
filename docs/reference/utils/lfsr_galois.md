# lfsr_galois

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/utils/lfsr.sv`](../../../rtl/utils/lfsr.sv) |
| Availability | Synthesizable RTL |

## Summary

Galois-form pseudo-random linear-feedback shift register.

## Functional Behavior

Galois-form pseudo-random linear-feedback shift register. Its exact parameters and ports are reproduced below from the implementation declaration.

## Suitable Applications

Use as a small reusable datapath, state, coding, delay, or verification primitive.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int                    DATA_WIDTH = 32` |
| `POLY` | `parameter logic [DATA_WIDTH-1:0] POLY       = {{(DATA_WIDTH - 1) {1'b0}}, 1'b1}` |
| `RESET_SEED` | `parameter logic [DATA_WIDTH-1:0] RESET_SEED = {{(DATA_WIDTH - 1) {1'b0}}, 1'b1}` |

## Interface Definition

```systemverilog
module lfsr_galois #(
    parameter int                    DATA_WIDTH = 32,
    parameter logic [DATA_WIDTH-1:0] POLY       = {{(DATA_WIDTH - 1) {1'b0}}, 1'b1},
    parameter logic [DATA_WIDTH-1:0] RESET_SEED = {{(DATA_WIDTH - 1) {1'b0}}, 1'b1}
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  wr_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] dat_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                  clk_i` |
| `rst_n_i` | `input` | `input  logic                  rst_n_i` |
| `wr_i` | `input` | `input  logic                  wr_i` |
| `dat_i` | `input` | `input  logic [DATA_WIDTH-1:0] dat_i` |
| `dat_o` | `output` | `output logic [DATA_WIDTH-1:0] dat_o` |

## Integration and Use

Keep parameter values within RTL assertions and add required clocking, reset, or CDC protection at the caller boundary.

```systemverilog
lfsr_galois #(
    .DATA_WIDTH(DATA_WIDTH),
    .POLY(POLY),
    .RESET_SEED(RESET_SEED)
) u_lfsr_galois (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .wr_i(wr_i),
    .dat_i(dat_i),
    .dat_o(dat_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
