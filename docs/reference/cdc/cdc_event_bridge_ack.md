# cdc_event_bridge_ack

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/cdc/cdc_advanced.sv`](../../../rtl/cdc/cdc_advanced.sv) |
| Availability | Synthesizable RTL |

## Summary

Acknowledged asynchronous event transport.

## Functional Behavior

Acknowledged asynchronous event transport. It carries the declared control, event, or data contract through the stated synchronizer, handshake, or Gray-pointer mechanism. Endpoint reset discards in-flight data unless the page identifies an acknowledged warm-clear path.

## Suitable Applications

Use for reset release, asynchronous control/data transfer, asynchronous queues, event notification, and CDC recovery.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `SYNC_STAGES` | `parameter int SYNC_STAGES = 2` |

## Interface Definition

```systemverilog
module cdc_event_bridge_ack #(
    parameter int SYNC_STAGES = 2
) (
    input  logic src_clk_i,
    input  logic src_rst_n_i,
    input  logic event_i,
    output logic accepted_o,
    output logic completed_o,
    input  logic dst_clk_i,
    input  logic dst_rst_n_i,
    output logic event_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `src_clk_i` | `input` | `input  logic src_clk_i` |
| `src_rst_n_i` | `input` | `input  logic src_rst_n_i` |
| `event_i` | `input` | `input  logic event_i` |
| `accepted_o` | `output` | `output logic accepted_o` |
| `completed_o` | `output` | `output logic completed_o` |
| `dst_clk_i` | `input` | `input  logic dst_clk_i` |
| `dst_rst_n_i` | `input` | `input  logic dst_rst_n_i` |
| `event_o` | `output` | `output logic event_o` |

## Integration and Use

Never use a simple synchronizer for arbitrary multi-bit data. Keep both endpoint clocks running after reset release and obey all ready/busy outputs.

```systemverilog
cdc_event_bridge_ack #(
    .SYNC_STAGES(SYNC_STAGES)
) u_cdc_event_bridge_ack (
    .src_clk_i(src_clk_i),
    .src_rst_n_i(src_rst_n_i),
    .event_i(event_i),
    .accepted_o(accepted_o),
    .completed_o(completed_o),
    .dst_clk_i(dst_clk_i),
    .dst_rst_n_i(dst_rst_n_i),
    .event_o(event_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
