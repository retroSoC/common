# xchecker

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/utils/xchecker.sv`](../../../rtl/utils/xchecker.sv) |
| Availability | Simulation/verification model |

## Summary

Simulation unknown-value checker.

## Functional Behavior

Simulation unknown-value checker. Its exact parameters and ports are reproduced below from the implementation declaration.

## Suitable Applications

Use as a small reusable datapath, state, coding, delay, or verification primitive.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter DATA_WIDTH = 1` |

## Interface Definition

```systemverilog
module xchecker #(
    parameter DATA_WIDTH = 1
) (
    input logic                  clk_i,
    input logic [DATA_WIDTH-1:0] dat_i
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input logic                  clk_i` |
| `dat_i` | `input` | `input logic [DATA_WIDTH-1:0] dat_i` |

## Integration and Use

Keep parameter values within RTL assertions and add required clocking, reset, or CDC protection at the caller boundary.

```systemverilog
xchecker #(
    .DATA_WIDTH(DATA_WIDTH)
) u_xchecker (
    .clk_i(clk_i),
    .dat_i(dat_i)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
