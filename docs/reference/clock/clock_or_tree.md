# clock_or_tree

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/clock/clock_tree.sv`](../../../rtl/clock/clock_tree.sv) |
| Availability | Synthesizable RTL |

## Summary

OR tree for clocks already proven safe to combine.

## Functional Behavior

OR tree for clocks already proven safe to combine. It implements the declared clock/reset behavior but does not replace physical clock-tree, reset-domain, or STA signoff.

## Suitable Applications

Use in controlled clock/reset infrastructure with explicit physical-design ownership.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `CLOCKS` | `parameter int CLOCKS = 2` |

## Interface Definition

```systemverilog
module clock_or_tree #(
    parameter int CLOCKS = 2
) (
    input  logic [CLOCKS-1:0] clock_i,
    output logic              clock_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clock_i` | `input` | `input  logic [CLOCKS-1:0] clock_i` |
| `clock_o` | `output` | `output logic              clock_o` |

## Integration and Use

Respect all clock-running and configuration-stability assumptions. Do not use generic logic as a substitute for a safe clock-control cell.

```systemverilog
clock_or_tree #(
    .CLOCKS(CLOCKS)
) u_clock_or_tree (
    .clock_i(clock_i),
    .clock_o(clock_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
