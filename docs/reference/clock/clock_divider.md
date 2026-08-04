# clock_divider

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/clock/clock_divider.sv`](../../../rtl/clock/clock_divider.sv) |
| Availability | Synthesizable RTL |

## Summary

Runtime-programmable divider that changes only at an output-low boundary.

## Functional Behavior

Runtime-programmable divider that changes only at an output-low boundary. It implements the declared clock/reset behavior but does not replace physical clock-tree, reset-domain, or STA signoff.

## Suitable Applications

Use in controlled clock/reset infrastructure with explicit physical-design ownership.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DIV_WIDTH` | `parameter int                   DIV_WIDTH = 16` |
| `RESET_DIV` | `parameter logic [DIV_WIDTH-1:0] RESET_DIV = 1` |

## Interface Definition

```systemverilog
module clock_divider #(
    parameter int                   DIV_WIDTH = 16,
    parameter logic [DIV_WIDTH-1:0] RESET_DIV = 1
) (
    input  logic                 clk_i,
    input  logic                 rst_n_i,
    input  logic                 enable_i,
    input  logic [DIV_WIDTH-1:0] div_i,
    input  logic                 div_valid_i,
    output logic                 div_ready_o,
    output logic                 clk_o,
    output logic [DIV_WIDTH-1:0] count_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                 clk_i` |
| `rst_n_i` | `input` | `input  logic                 rst_n_i` |
| `enable_i` | `input` | `input  logic                 enable_i` |
| `div_i` | `input` | `input  logic [DIV_WIDTH-1:0] div_i` |
| `div_valid_i` | `input` | `input  logic                 div_valid_i` |
| `div_ready_o` | `output` | `output logic                 div_ready_o` |
| `clk_o` | `output` | `output logic                 clk_o` |
| `count_o` | `output` | `output logic [DIV_WIDTH-1:0] count_o` |

## Integration and Use

Respect all clock-running and configuration-stability assumptions. Do not use generic logic as a substitute for a safe clock-control cell.

```systemverilog
clock_divider #(
    .DIV_WIDTH(DIV_WIDTH),
    .RESET_DIV(RESET_DIV)
) u_clock_divider (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .enable_i(enable_i),
    .div_i(div_i),
    .div_valid_i(div_valid_i),
    .div_ready_o(div_ready_o),
    .clk_o(clk_o),
    .count_o(count_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
