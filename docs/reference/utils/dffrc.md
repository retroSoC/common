# dffrc

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/utils/register.sv`](../../../rtl/utils/register.sv) |
| Availability | Synthesizable RTL |

## Summary

D flip-flop with configurable reset value.

## Functional Behavior

D flip-flop with configurable reset value. Its exact parameters and ports are reproduced below from the implementation declaration.

## Suitable Applications

Use as a small reusable datapath, state, coding, delay, or verification primitive.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int                    DATA_WIDTH = 1` |
| `RESET_VAL` | `parameter logic [DATA_WIDTH-1:0] RESET_VAL  = '0` |

## Interface Definition

```systemverilog
module dffrc #(
    parameter int                    DATA_WIDTH = 1,
    parameter logic [DATA_WIDTH-1:0] RESET_VAL  = '0
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] dat_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                  clk_i` |
| `rst_n_i` | `input` | `input  logic                  rst_n_i` |
| `dat_i` | `input` | `input  logic [DATA_WIDTH-1:0] dat_i` |
| `dat_o` | `output` | `output logic [DATA_WIDTH-1:0] dat_o` |

## Integration and Use

Keep parameter values within RTL assertions and add required clocking, reset, or CDC protection at the caller boundary.

```systemverilog
dffrc #(
    .DATA_WIDTH(DATA_WIDTH),
    .RESET_VAL(RESET_VAL)
) u_dffrc (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .dat_i(dat_i),
    .dat_o(dat_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
