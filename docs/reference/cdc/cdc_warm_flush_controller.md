# cdc_warm_flush_controller

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/cdc/cdc_warm_flush.sv`](../../../rtl/cdc/cdc_warm_flush.sv) |
| Availability | Synthesizable RTL |

## Summary

Acknowledged isolate-reset-resume controller for CDC warm flush.

## Functional Behavior

Acknowledged isolate-reset-resume controller for CDC warm flush. It carries the declared control, event, or data contract through the stated synchronizer, handshake, or Gray-pointer mechanism. Endpoint reset discards in-flight data unless the page identifies an acknowledged warm-clear path.

## Suitable Applications

Use for reset release, asynchronous control/data transfer, asynchronous queues, event notification, and CDC recovery.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `SYNC_STAGES` | `parameter int SYNC_STAGES = 2` |

## Interface Definition

```systemverilog
module cdc_warm_flush_controller #(
    parameter int SYNC_STAGES = 2
) (
    input  logic src_clk_i,
    input  logic src_rst_n_i,
    input  logic src_clear_i,
    output logic src_isolate_o,
    output logic src_reset_o,
    output logic src_busy_o,

    input  logic dst_clk_i,
    input  logic dst_rst_n_i,
    output logic dst_isolate_o,
    output logic dst_reset_o,
    output logic dst_busy_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `src_clk_i` | `input` | `input  logic src_clk_i` |
| `src_rst_n_i` | `input` | `input  logic src_rst_n_i` |
| `src_clear_i` | `input` | `input  logic src_clear_i` |
| `src_isolate_o` | `output` | `output logic src_isolate_o` |
| `src_reset_o` | `output` | `output logic src_reset_o` |
| `src_busy_o` | `output` | `output logic src_busy_o` |
| `dst_clk_i` | `input` | `input  logic dst_clk_i` |
| `dst_rst_n_i` | `input` | `input  logic dst_rst_n_i` |
| `dst_isolate_o` | `output` | `output logic dst_isolate_o` |
| `dst_reset_o` | `output` | `output logic dst_reset_o` |
| `dst_busy_o` | `output` | `output logic dst_busy_o` |

## Integration and Use

Never use a simple synchronizer for arbitrary multi-bit data. Keep both endpoint clocks running after reset release and obey all ready/busy outputs.

```systemverilog
cdc_warm_flush_controller #(
    .SYNC_STAGES(SYNC_STAGES)
) u_cdc_warm_flush_controller (
    .src_clk_i(src_clk_i),
    .src_rst_n_i(src_rst_n_i),
    .src_clear_i(src_clear_i),
    .src_isolate_o(src_isolate_o),
    .src_reset_o(src_reset_o),
    .src_busy_o(src_busy_o),
    .dst_clk_i(dst_clk_i),
    .dst_rst_n_i(dst_rst_n_i),
    .dst_isolate_o(dst_isolate_o),
    .dst_reset_o(dst_reset_o),
    .dst_busy_o(dst_busy_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
