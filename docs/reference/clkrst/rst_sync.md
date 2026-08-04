# rst_sync

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/clkrst/rst_sync.sv`](../../../rtl/clkrst/rst_sync.sv) |
| Availability | Synthesizable RTL |

## Summary

Asynchronous-assert, synchronous-release reset synchronizer.

## Functional Behavior

Asynchronous-assert, synchronous-release reset synchronizer. It implements the declared clock/reset behavior but does not replace physical clock-tree, reset-domain, or STA signoff.

## Suitable Applications

Use in controlled clock/reset infrastructure with explicit physical-design ownership.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `STAGE` | `parameter int STAGE = 3` |

## Interface Definition

```systemverilog
module rst_sync #(
    parameter int STAGE = 3
) (
    input  logic clk_i,
    input  logic rst_n_i,
    output logic rst_n_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic clk_i` |
| `rst_n_i` | `input` | `input  logic rst_n_i` |
| `rst_n_o` | `output` | `output logic rst_n_o` |

## Integration and Use

Respect all clock-running and configuration-stability assumptions. Do not use generic logic as a substitute for a safe clock-control cell.

```systemverilog
rst_sync #(
    .STAGE(STAGE)
) u_rst_sync (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .rst_n_o(rst_n_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
