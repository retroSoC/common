# clk_int_even_div

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/clkrst/clk_int_div.sv`](../../../rtl/clkrst/clk_int_div.sv) |
| Availability | Synthesizable RTL |

## Summary

Even clock divider retaining requests until a safe boundary.

## Functional Behavior

Even clock divider retaining requests until a safe boundary. It implements the declared clock/reset behavior but does not replace physical clock-tree, reset-domain, or STA signoff.

## Suitable Applications

Use in controlled clock/reset infrastructure with explicit physical-design ownership.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DIV_VALUE` | `parameter int DIV_VALUE             = 2` |
| `ENABLE_CLOCK_IN_RESET` | `parameter bit ENABLE_CLOCK_IN_RESET = 1'b0` |

## Interface Definition

```systemverilog
module clk_int_even_div #(
    parameter int DIV_VALUE             = 2,
    parameter bit ENABLE_CLOCK_IN_RESET = 1'b0
) (
    input  logic clk_i,
    input  logic rst_n_i,
    input  logic en_i,
    input  logic div_i,
    input  logic div_valid_i,
    output logic div_done_o,
    output logic clk_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic clk_i` |
| `rst_n_i` | `input` | `input  logic rst_n_i` |
| `en_i` | `input` | `input  logic en_i` |
| `div_i` | `input` | `input  logic div_i` |
| `div_valid_i` | `input` | `input  logic div_valid_i` |
| `div_done_o` | `output` | `output logic div_done_o` |
| `clk_o` | `output` | `output logic clk_o` |

## Integration and Use

Respect all clock-running and configuration-stability assumptions. Do not use generic logic as a substitute for a safe clock-control cell.

```systemverilog
clk_int_even_div #(
    .DIV_VALUE(DIV_VALUE),
    .ENABLE_CLOCK_IN_RESET(ENABLE_CLOCK_IN_RESET)
) u_clk_int_even_div (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .en_i(en_i),
    .div_i(div_i),
    .div_valid_i(div_valid_i),
    .div_done_o(div_done_o),
    .clk_o(clk_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
