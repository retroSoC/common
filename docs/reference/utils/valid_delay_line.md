# valid_delay_line

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/utils/valid_delay_line.sv`](../../../rtl/utils/valid_delay_line.sv) |
| Availability | Synthesizable RTL |

## Summary

Valid-only parameterized sequential delay line.

## Functional Behavior

Valid-only parameterized sequential delay line. Its exact parameters and ports are reproduced below from the implementation declaration.

## Suitable Applications

Use as a small reusable datapath, state, coding, delay, or verification primitive.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 32` |
| `DEPTH` | `parameter int DEPTH      = 2` |

## Interface Definition

```systemverilog
module valid_delay_line #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 2
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  clear_i,
    input  logic                  in_valid_i,
    input  logic [DATA_WIDTH-1:0] in_data_i,
    output logic                  out_valid_o,
    output logic [DATA_WIDTH-1:0] out_data_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                  clk_i` |
| `rst_n_i` | `input` | `input  logic                  rst_n_i` |
| `clear_i` | `input` | `input  logic                  clear_i` |
| `in_valid_i` | `input` | `input  logic                  in_valid_i` |
| `in_data_i` | `input` | `input  logic [DATA_WIDTH-1:0] in_data_i` |
| `out_valid_o` | `output` | `output logic                  out_valid_o` |
| `out_data_o` | `output` | `output logic [DATA_WIDTH-1:0] out_data_o` |

## Integration and Use

Keep parameter values within RTL assertions and add required clocking, reset, or CDC protection at the caller boundary.

```systemverilog
valid_delay_line #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH)
) u_valid_delay_line (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .clear_i(clear_i),
    .in_valid_i(in_valid_i),
    .in_data_i(in_data_i),
    .out_valid_o(out_valid_o),
    .out_data_o(out_data_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
