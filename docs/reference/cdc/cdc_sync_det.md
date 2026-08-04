# cdc_sync_det

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/cdc/cdc_sync.sv`](../../../rtl/cdc/cdc_sync.sv) |
| Availability | Synthesizable RTL |

## Summary

Synchronized control input with edge detection.

## Functional Behavior

Synchronized control input with edge detection. It carries the declared control, event, or data contract through the stated synchronizer, handshake, or Gray-pointer mechanism. Endpoint reset discards in-flight data unless the page identifies an acknowledged warm-clear path.

## Suitable Applications

Use for reset release, asynchronous control/data transfer, asynchronous queues, event notification, and CDC recovery.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `STAGE` | `parameter int STAGE      = 2` |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 1` |

## Interface Definition

```systemverilog
module cdc_sync_det #(
    parameter int STAGE      = 2,
    parameter int DATA_WIDTH = 1
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] dat_pre_o,
    output logic [DATA_WIDTH-1:0] dat_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                  clk_i` |
| `rst_n_i` | `input` | `input  logic                  rst_n_i` |
| `dat_i` | `input` | `input  logic [DATA_WIDTH-1:0] dat_i` |
| `dat_pre_o` | `output` | `output logic [DATA_WIDTH-1:0] dat_pre_o` |
| `dat_o` | `output` | `output logic [DATA_WIDTH-1:0] dat_o` |

## Integration and Use

Never use a simple synchronizer for arbitrary multi-bit data. Keep both endpoint clocks running after reset release and obey all ready/busy outputs.

```systemverilog
cdc_sync_det #(
    .STAGE(STAGE),
    .DATA_WIDTH(DATA_WIDTH)
) u_cdc_sync_det (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .dat_i(dat_i),
    .dat_pre_o(dat_pre_o),
    .dat_o(dat_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
