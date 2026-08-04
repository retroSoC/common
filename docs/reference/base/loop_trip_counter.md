# loop_trip_counter

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/base/control_cells.sv`](../../../rtl/base/control_cells.sv) |
| Availability | Synthesizable RTL |

## Summary

Programmable terminal-count loop counter.

## Functional Behavior

Increments by `step_i` on `advance_i`. When the stored value equals `limit_i`, the next advance pulses `wrap_o` and returns the state to zero.

## Suitable Applications

Use for bounded loops, beat scheduling, table traversal, and phase sequencing.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 4` |

## Interface Definition

```systemverilog
module loop_trip_counter #(
    parameter int DATA_WIDTH = 4
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  clear_i,
    input  logic                  advance_i,
    input  logic [DATA_WIDTH-1:0] step_i,
    input  logic [DATA_WIDTH-1:0] limit_i,
    output logic [DATA_WIDTH-1:0] value_o,
    output logic                  at_limit_o,
    output logic                  wrap_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                  clk_i` |
| `rst_n_i` | `input` | `input  logic                  rst_n_i` |
| `clear_i` | `input` | `input  logic                  clear_i` |
| `advance_i` | `input` | `input  logic                  advance_i` |
| `step_i` | `input` | `input  logic [DATA_WIDTH-1:0] step_i` |
| `limit_i` | `input` | `input  logic [DATA_WIDTH-1:0] limit_i` |
| `value_o` | `output` | `output logic [DATA_WIDTH-1:0] value_o` |
| `at_limit_o` | `output` | `output logic                  at_limit_o` |
| `wrap_o` | `output` | `output logic                  wrap_o` |

## Integration and Use

A nonzero step must reach the limit exactly. This is not an arbitrary modulo counter; skipping the terminal value is an error.

```systemverilog
loop_trip_counter #(
    .DATA_WIDTH(DATA_WIDTH)
) u_loop_trip_counter (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .clear_i(clear_i),
    .advance_i(advance_i),
    .step_i(step_i),
    .limit_i(limit_i),
    .value_o(value_o),
    .at_limit_o(at_limit_o),
    .wrap_o(wrap_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
