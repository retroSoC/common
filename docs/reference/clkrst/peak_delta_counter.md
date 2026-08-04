# peak_delta_counter

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/clkrst/counter.sv`](../../../rtl/clkrst/counter.sv) |
| Availability | Synthesizable RTL |

## Summary

Up/down counter with retained high-water mark.

## Functional Behavior

Up/down counter with retained high-water mark. It implements the declared clock/reset behavior but does not replace physical clock-tree, reset-domain, or STA signoff.

## Suitable Applications

Use in controlled clock/reset infrastructure with explicit physical-design ownership.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 4` |

## Interface Definition

```systemverilog
module peak_delta_counter #(
    parameter int DATA_WIDTH = 4
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  flush_i,
    input  logic                  clear_value_i,
    input  logic                  clear_peak_i,
    input  logic                  enable_i,
    input  logic                  load_i,
    input  logic                  subtract_i,
    input  logic [DATA_WIDTH-1:0] step_i,
    input  logic [DATA_WIDTH-1:0] load_value_i,
    output logic [DATA_WIDTH-1:0] value_o,
    output logic [DATA_WIDTH-1:0] peak_o,
    output logic                  value_overflow_o,
    output logic                  peak_overflow_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                  clk_i` |
| `rst_n_i` | `input` | `input  logic                  rst_n_i` |
| `flush_i` | `input` | `input  logic                  flush_i` |
| `clear_value_i` | `input` | `input  logic                  clear_value_i` |
| `clear_peak_i` | `input` | `input  logic                  clear_peak_i` |
| `enable_i` | `input` | `input  logic                  enable_i` |
| `load_i` | `input` | `input  logic                  load_i` |
| `subtract_i` | `input` | `input  logic                  subtract_i` |
| `step_i` | `input` | `input  logic [DATA_WIDTH-1:0] step_i` |
| `load_value_i` | `input` | `input  logic [DATA_WIDTH-1:0] load_value_i` |
| `value_o` | `output` | `output logic [DATA_WIDTH-1:0] value_o` |
| `peak_o` | `output` | `output logic [DATA_WIDTH-1:0] peak_o` |
| `value_overflow_o` | `output` | `output logic                  value_overflow_o` |
| `peak_overflow_o` | `output` | `output logic                  peak_overflow_o` |

## Integration and Use

Respect all clock-running and configuration-stability assumptions. Do not use generic logic as a substitute for a safe clock-control cell.

```systemverilog
peak_delta_counter #(
    .DATA_WIDTH(DATA_WIDTH)
) u_peak_delta_counter (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .flush_i(flush_i),
    .clear_value_i(clear_value_i),
    .clear_peak_i(clear_peak_i),
    .enable_i(enable_i),
    .load_i(load_i),
    .subtract_i(subtract_i),
    .step_i(step_i),
    .load_value_i(load_value_i),
    .value_o(value_o),
    .peak_o(peak_o),
    .value_overflow_o(value_overflow_o),
    .peak_overflow_o(peak_overflow_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
