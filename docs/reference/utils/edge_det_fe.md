# edge_det_fe

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/utils/edge_det.sv`](../../../rtl/utils/edge_det.sv) |
| Availability | Synthesizable RTL |

## Summary

Single-bit falling-edge detector.

## Functional Behavior

Single-bit falling-edge detector. Its exact parameters and ports are reproduced below from the implementation declaration.

## Suitable Applications

Use as a small reusable datapath, state, coding, delay, or verification primitive.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `STAGE` | `parameter int STAGE      = 2` |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 1` |

## Interface Definition

```systemverilog
module edge_det_fe #(
    parameter int STAGE      = 2,
    parameter int DATA_WIDTH = 1
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] fe_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                  clk_i` |
| `rst_n_i` | `input` | `input  logic                  rst_n_i` |
| `dat_i` | `input` | `input  logic [DATA_WIDTH-1:0] dat_i` |
| `fe_o` | `output` | `output logic [DATA_WIDTH-1:0] fe_o` |

## Integration and Use

Keep parameter values within RTL assertions and add required clocking, reset, or CDC protection at the caller boundary.

```systemverilog
edge_det_fe #(
    .STAGE(STAGE),
    .DATA_WIDTH(DATA_WIDTH)
) u_edge_det_fe (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .dat_i(dat_i),
    .fe_o(fe_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
