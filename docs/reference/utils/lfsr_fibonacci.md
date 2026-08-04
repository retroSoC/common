# lfsr_fibonacci

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/utils/lfsr.sv`](../../../rtl/utils/lfsr.sv) |
| Availability | Synthesizable RTL |

## Summary

Fibonacci-form pseudo-random linear-feedback shift register.

## Functional Behavior

Fibonacci-form pseudo-random linear-feedback shift register. Its exact parameters and ports are reproduced below from the implementation declaration.

## Suitable Applications

Use as a small reusable datapath, state, coding, delay, or verification primitive.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 32` |
| `SEED` | `parameter int SEED       = 0` |

## Interface Definition

```systemverilog
module lfsr_fibonacci #(
    parameter int DATA_WIDTH = 32,
    parameter int SEED       = 0
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
lfsr_fibonacci #(
    .DATA_WIDTH(DATA_WIDTH),
    .SEED(SEED)
) u_lfsr_fibonacci (
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
