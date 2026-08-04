# synchronized_edge

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/cdc/cdc_advanced.sv`](../../../rtl/cdc/cdc_advanced.sv) |
| Availability | Synthesizable RTL |

## Summary

Synchronizes a control transition and emits a local edge indication.

## Functional Behavior

Synchronizes a control transition and emits a local edge indication. It carries the declared control, event, or data contract through the stated synchronizer, handshake, or Gray-pointer mechanism. Endpoint reset discards in-flight data unless the page identifies an acknowledged warm-clear path.

## Suitable Applications

Use for reset release, asynchronous control/data transfer, asynchronous queues, event notification, and CDC recovery.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `SYNC_STAGES` | `parameter int SYNC_STAGES = 2` |

## Interface Definition

```systemverilog
module synchronized_edge #(
    parameter int SYNC_STAGES = 2
) (
    input  logic clk_i,
    input  logic rst_n_i,
    input  logic clear_i,
    input  logic enable_i,
    input  logic async_level_i,
    output logic level_o,
    output logic rise_o,
    output logic fall_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic clk_i` |
| `rst_n_i` | `input` | `input  logic rst_n_i` |
| `clear_i` | `input` | `input  logic clear_i` |
| `enable_i` | `input` | `input  logic enable_i` |
| `async_level_i` | `input` | `input  logic async_level_i` |
| `level_o` | `output` | `output logic level_o` |
| `rise_o` | `output` | `output logic rise_o` |
| `fall_o` | `output` | `output logic fall_o` |

## Integration and Use

Never use a simple synchronizer for arbitrary multi-bit data. Keep both endpoint clocks running after reset release and obey all ready/busy outputs.

```systemverilog
synchronized_edge #(
    .SYNC_STAGES(SYNC_STAGES)
) u_synchronized_edge (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .clear_i(clear_i),
    .enable_i(enable_i),
    .async_level_i(async_level_i),
    .level_o(level_o),
    .rise_o(rise_o),
    .fall_o(fall_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
