# cdc_remote_clear_request

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/cdc/cdc_advanced.sv`](../../../rtl/cdc/cdc_advanced.sv) |
| Availability | Synthesizable RTL |

## Summary

Retained remote-clear request channel.

## Functional Behavior

Retained remote-clear request channel. It carries the declared control, event, or data contract through the stated synchronizer, handshake, or Gray-pointer mechanism. Endpoint reset discards in-flight data unless the page identifies an acknowledged warm-clear path.

## Suitable Applications

Use for reset release, asynchronous control/data transfer, asynchronous queues, event notification, and CDC recovery.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `SYNC_STAGES` | `parameter int SYNC_STAGES = 3` |

## Interface Definition

```systemverilog
module cdc_remote_clear_request #(
    parameter int SYNC_STAGES = 3
) (
    input  logic request_clk_i,
    input  logic request_rst_n_i,
    input  logic request_i,
    output logic request_busy_o,
    input  logic accept_clk_i,
    input  logic accept_rst_n_i,
    output logic accept_valid_o,
    input  logic accept_ready_i
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `request_clk_i` | `input` | `input  logic request_clk_i` |
| `request_rst_n_i` | `input` | `input  logic request_rst_n_i` |
| `request_i` | `input` | `input  logic request_i` |
| `request_busy_o` | `output` | `output logic request_busy_o` |
| `accept_clk_i` | `input` | `input  logic accept_clk_i` |
| `accept_rst_n_i` | `input` | `input  logic accept_rst_n_i` |
| `accept_valid_o` | `output` | `output logic accept_valid_o` |
| `accept_ready_i` | `input` | `input  logic accept_ready_i` |

## Integration and Use

Never use a simple synchronizer for arbitrary multi-bit data. Keep both endpoint clocks running after reset release and obey all ready/busy outputs.

```systemverilog
cdc_remote_clear_request #(
    .SYNC_STAGES(SYNC_STAGES)
) u_cdc_remote_clear_request (
    .request_clk_i(request_clk_i),
    .request_rst_n_i(request_rst_n_i),
    .request_i(request_i),
    .request_busy_o(request_busy_o),
    .accept_clk_i(accept_clk_i),
    .accept_rst_n_i(accept_rst_n_i),
    .accept_valid_o(accept_valid_o),
    .accept_ready_i(accept_ready_i)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
