# ndffer

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/utils/register.sv`](../../../rtl/utils/register.sv) |
| Availability | Synthesizable RTL |

## Summary

Enabled D flip-flop with falling-edge clock and asynchronous reset.

## Functional Behavior

Samples `dat_i` on the falling edge of `clk_i` when `en_i` is high and asynchronously clears the output to zero when `rst_n_i` is low.

## Suitable Applications

Use for falling-edge state machines, phase-aligned control, or interfaces that intentionally sample on the opposite clock edge.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 1` |

## Interface Definition

```systemverilog
module ndffer #(
    parameter int DATA_WIDTH = 1
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  en_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] dat_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                  clk_i` |
| `rst_n_i` | `input` | `input  logic                  rst_n_i` |
| `en_i` | `input` | `input  logic                  en_i` |
| `dat_i` | `input` | `input  logic [DATA_WIDTH-1:0] dat_i` |
| `dat_o` | `output` | `output logic [DATA_WIDTH-1:0] dat_o` |

## Integration and Use

Use only when the falling-edge timing domain is explicit. `rst_n_i` has priority over `en_i`, and stalled enable retains the previous value.

```systemverilog
ndffer #(
    .DATA_WIDTH(DATA_WIDTH)
) u_ndffer (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .en_i(en_i),
    .dat_i(dat_i),
    .dat_o(dat_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
