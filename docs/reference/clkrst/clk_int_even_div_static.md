# clk_int_even_div_static

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/clkrst/clk_int_div.sv`](../../../rtl/clkrst/clk_int_div.sv) |
| Availability | Synthesizable RTL |

## Summary

Static even integer clock divider.

## Functional Behavior

Static even integer clock divider. It implements the declared clock/reset behavior but does not replace physical clock-tree, reset-domain, or STA signoff.

## Suitable Applications

Use in controlled clock/reset infrastructure with explicit physical-design ownership.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DIV_VALUE_WIDTH` | `parameter int DIV_VALUE_WIDTH = 2` |

## Interface Definition

```systemverilog
module clk_int_even_div_static #(
    parameter int DIV_VALUE_WIDTH = 2
) (
    input  logic clk_i,
    input  logic rst_n_i,
    output logic clk_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic clk_i` |
| `rst_n_i` | `input` | `input  logic rst_n_i` |
| `clk_o` | `output` | `output logic clk_o` |

## Integration and Use

Respect all clock-running and configuration-stability assumptions. Do not use generic logic as a substitute for a safe clock-control cell.

```systemverilog
clk_int_even_div_static #(
    .DIV_VALUE_WIDTH(DIV_VALUE_WIDTH)
) u_clk_int_even_div_static (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .clk_o(clk_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
