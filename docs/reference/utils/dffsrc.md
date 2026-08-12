# dffsrc

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/utils/register.sv`](../../../rtl/utils/register.sv) |
| Availability | Synthesizable RTL |

## Summary

D flip-flop with synchronous reset and configurable reset value.

## Functional Behavior

Samples `dat_i` on the rising edge of `clk_i`; when `rst_n_i` is low at that edge, the output takes `RESET_VAL`.

## Suitable Applications

Use for synchronous-reset state or configuration registers that require a nonzero reset value.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int                    DATA_WIDTH = 1` |
| `RESET_VAL` | `parameter logic [DATA_WIDTH-1:0] RESET_VAL  = '0` |

## Interface Definition

```systemverilog
module dffsrc #(
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

The reset is synchronous: changing `rst_n_i` between clock edges does not change the output.

```systemverilog
dffsrc #(
    .DATA_WIDTH(DATA_WIDTH),
    .RESET_VAL(RESET_VAL)
) u_dffsrc (
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
