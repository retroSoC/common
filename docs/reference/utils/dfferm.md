# dfferm

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/utils/register.sv`](../../../rtl/utils/register.sv) |
| Availability | Synthesizable RTL |

## Summary

Masked-update D flip-flop with reset.

## Functional Behavior

Masked-update D flip-flop with reset. Its exact parameters and ports are reproduced below from the implementation declaration.

## Suitable Applications

Use as a small reusable datapath, state, coding, delay, or verification primitive.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_NUM` | `parameter int                  DATA_NUM   = 2` |
| `DATA_WIDTH` | `parameter int                  DATA_WIDTH = 1` |
| `INIT_VAL` | `parameter     [DATA_WIDTH-1:0] INIT_VAL   = '1` |

## Interface Definition

```systemverilog
module dfferm #(
    parameter int                  DATA_NUM   = 2,
    parameter int                  DATA_WIDTH = 1,
    parameter     [DATA_WIDTH-1:0] INIT_VAL   = '1
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic [  DATA_NUM-1:0] en_i,
    input  logic [DATA_WIDTH-1:0] dat_i  [0:DATA_NUM-1],
    output logic [DATA_WIDTH-1:0] dat_o  [0:DATA_NUM-1]
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                  clk_i` |
| `rst_n_i` | `input` | `input  logic                  rst_n_i` |
| `en_i` | `input` | `input  logic [  DATA_NUM-1:0] en_i` |

## Integration and Use

Keep parameter values within RTL assertions and add required clocking, reset, or CDC protection at the caller boundary.

```systemverilog
dfferm #(
    .DATA_NUM(DATA_NUM),
    .DATA_WIDTH(DATA_WIDTH),
    .INIT_VAL(INIT_VAL)
) u_dfferm (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .en_i(en_i)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
