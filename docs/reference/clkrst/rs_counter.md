# rs_counter

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/clkrst/counter.sv`](../../../rtl/clkrst/counter.sv) |
| Availability | Synthesizable RTL |

## Summary

Resettable up/down counter.

## Functional Behavior

Resettable up/down counter. It implements the declared clock/reset behavior but does not replace physical clock-tree, reset-domain, or STA signoff.

## Suitable Applications

Use in controlled clock/reset infrastructure with explicit physical-design ownership.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 4` |

## Interface Definition

```systemverilog
module rs_counter #(
    parameter int DATA_WIDTH = 4
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  clr_i,
    input  logic                  en_i,
    input  logic                  load_i,
    input  logic                  down_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] dat_o,
    output logic                  ovf_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                  clk_i` |
| `rst_n_i` | `input` | `input  logic                  rst_n_i` |
| `clr_i` | `input` | `input  logic                  clr_i` |
| `en_i` | `input` | `input  logic                  en_i` |
| `load_i` | `input` | `input  logic                  load_i` |
| `down_i` | `input` | `input  logic                  down_i` |
| `dat_i` | `input` | `input  logic [DATA_WIDTH-1:0] dat_i` |
| `dat_o` | `output` | `output logic [DATA_WIDTH-1:0] dat_o` |
| `ovf_o` | `output` | `output logic                  ovf_o` |

## Integration and Use

Respect all clock-running and configuration-stability assumptions. Do not use generic logic as a substitute for a safe clock-control cell.

```systemverilog
rs_counter #(
    .DATA_WIDTH(DATA_WIDTH)
) u_rs_counter (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .clr_i(clr_i),
    .en_i(en_i),
    .load_i(load_i),
    .down_i(down_i),
    .dat_i(dat_i),
    .dat_o(dat_o),
    .ovf_o(ovf_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
