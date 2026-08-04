# clk_int_div_simple

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/clkrst/clk_int_div.sv`](../../../rtl/clkrst/clk_int_div.sv) |
| Availability | Synthesizable RTL |

## Summary

Runtime-programmable integer divider with safe low-phase updates.

## Functional Behavior

Runtime-programmable integer divider with safe low-phase updates. It implements the declared clock/reset behavior but does not replace physical clock-tree, reset-domain, or STA signoff.

## Suitable Applications

Use in controlled clock/reset infrastructure with explicit physical-design ownership.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DIV_VALUE_WIDTH` | `parameter int DIV_VALUE_WIDTH  = 32` |
| `DONE_DELAY_WIDTH` | `parameter int DONE_DELAY_WIDTH = 3` |

## Interface Definition

```systemverilog
module clk_int_div_simple #(
    parameter int DIV_VALUE_WIDTH  = 32,
    parameter int DONE_DELAY_WIDTH = 3
) (
    input  logic                       clk_i,
    input  logic                       rst_n_i,
    input  logic [DIV_VALUE_WIDTH-1:0] div_i,
    input  logic                       clk_init_i,
    input  logic                       div_valid_i,
    output logic                       div_ready_o,
    output logic                       div_done_o,
    output logic [DIV_VALUE_WIDTH-1:0] clk_cnt_o,
    output logic                       clk_fir_trg_o,
    output logic                       clk_sec_trg_o,
    output logic                       clk_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                       clk_i` |
| `rst_n_i` | `input` | `input  logic                       rst_n_i` |
| `div_i` | `input` | `input  logic [DIV_VALUE_WIDTH-1:0] div_i` |
| `clk_init_i` | `input` | `input  logic                       clk_init_i` |
| `div_valid_i` | `input` | `input  logic                       div_valid_i` |
| `div_ready_o` | `output` | `output logic                       div_ready_o` |
| `div_done_o` | `output` | `output logic                       div_done_o` |
| `clk_cnt_o` | `output` | `output logic [DIV_VALUE_WIDTH-1:0] clk_cnt_o` |
| `clk_fir_trg_o` | `output` | `output logic                       clk_fir_trg_o` |
| `clk_sec_trg_o` | `output` | `output logic                       clk_sec_trg_o` |
| `clk_o` | `output` | `output logic                       clk_o` |

## Integration and Use

Respect all clock-running and configuration-stability assumptions. Do not use generic logic as a substitute for a safe clock-control cell.

```systemverilog
clk_int_div_simple #(
    .DIV_VALUE_WIDTH(DIV_VALUE_WIDTH),
    .DONE_DELAY_WIDTH(DONE_DELAY_WIDTH)
) u_clk_int_div_simple (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .div_i(div_i),
    .clk_init_i(clk_init_i),
    .div_valid_i(div_valid_i),
    .div_ready_o(div_ready_o),
    .div_done_o(div_done_o),
    .clk_cnt_o(clk_cnt_o),
    .clk_fir_trg_o(clk_fir_trg_o),
    .clk_sec_trg_o(clk_sec_trg_o),
    .clk_o(clk_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
