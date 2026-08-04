# dffercn

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/utils/register.sv`](../../../rtl/utils/register.sv) |
| Availability | Synthesizable RTL |

## Summary

Enabled D flip-flop with active-low configurable reset value.

## Functional Behavior

Enabled D flip-flop with active-low configurable reset value. Its exact parameters and ports are reproduced below from the implementation declaration.

## Suitable Applications

Use as a small reusable datapath, state, coding, delay, or verification primitive.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `REG_TYPE` | `parameter type     REG_TYPE  = logic` |
| `RESET_VAL` | `parameter REG_TYPE RESET_VAL = '0` |

## Interface Definition

```systemverilog
module dffercn #(
    parameter type     REG_TYPE  = logic,
    parameter REG_TYPE RESET_VAL = '0
) (
    input  logic    clk_i,
    input  logic    rst_n_i,
    input  logic    en_i,
    input  REG_TYPE dat_i,
    output REG_TYPE dat_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic    clk_i` |
| `rst_n_i` | `input` | `input  logic    rst_n_i` |
| `en_i` | `input` | `input  logic    en_i` |

## Integration and Use

Keep parameter values within RTL assertions and add required clocking, reset, or CDC protection at the caller boundary.

```systemverilog
dffercn #(
    .REG_TYPE(REG_TYPE),
    .RESET_VAL(RESET_VAL)
) u_dffercn (
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
