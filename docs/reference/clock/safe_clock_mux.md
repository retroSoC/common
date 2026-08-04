# safe_clock_mux

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/clock/safe_clock_mux.sv`](../../../rtl/clock/safe_clock_mux.sv) |
| Availability | Synthesizable RTL |

## Summary

Glitch-safe handover mux for two continuously running clocks.

## Functional Behavior

Glitch-safe handover mux for two continuously running clocks. It implements the declared clock/reset behavior but does not replace physical clock-tree, reset-domain, or STA signoff.

## Suitable Applications

Use in controlled clock/reset infrastructure with explicit physical-design ownership.

## Parameters

This unit has no configurable parameters.

## Interface Definition

```systemverilog
module safe_clock_mux (
    input  logic clk0_i,
    input  logic clk1_i,
    input  logic rst_n_i,
    input  logic select_i,
    output logic clk_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk0_i` | `input` | `input  logic clk0_i` |
| `clk1_i` | `input` | `input  logic clk1_i` |
| `rst_n_i` | `input` | `input  logic rst_n_i` |
| `select_i` | `input` | `input  logic select_i` |
| `clk_o` | `output` | `output logic clk_o` |

## Integration and Use

Respect all clock-running and configuration-stability assumptions. Do not use generic logic as a substitute for a safe clock-control cell.

```systemverilog
safe_clock_mux u_safe_clock_mux (
    .clk0_i(clk0_i),
    .clk1_i(clk1_i),
    .rst_n_i(rst_n_i),
    .select_i(select_i),
    .clk_o(clk_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
