# cdc_2phase_dst

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/cdc/cdc_2phase.sv`](../../../rtl/cdc/cdc_2phase.sv) |
| Availability | Synthesizable RTL |

## Summary

Destination-side implementation of the two-phase CDC link.

## Functional Behavior

Destination-side implementation of the two-phase CDC link. It carries the declared control, event, or data contract through the stated synchronizer, handshake, or Gray-pointer mechanism. Endpoint reset discards in-flight data unless the page identifies an acknowledged warm-clear path.

## Suitable Applications

Use for reset release, asynchronous control/data transfer, asynchronous queues, event notification, and CDC recovery.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH  = 32` |
| `SYNC_STAGES` | `parameter int SYNC_STAGES = 2` |

## Interface Definition

```systemverilog
module cdc_2phase_dst #(
    parameter int DATA_WIDTH  = 32,
    parameter int SYNC_STAGES = 2
) (
    input  logic                  rst_n_i,
    input  logic                  clk_i,
    output logic [DATA_WIDTH-1:0] data_o,
    output logic                  valid_o,
    input  logic                  ready_i,
    input  logic                  async_req_i,
    output logic                  async_ack_o,
    input  logic [DATA_WIDTH-1:0] async_data_i
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `rst_n_i` | `input` | `input  logic                  rst_n_i` |
| `clk_i` | `input` | `input  logic                  clk_i` |
| `data_o` | `output` | `output logic [DATA_WIDTH-1:0] data_o` |
| `valid_o` | `output` | `output logic                  valid_o` |
| `ready_i` | `input` | `input  logic                  ready_i` |
| `async_req_i` | `input` | `input  logic                  async_req_i` |
| `async_ack_o` | `output` | `output logic                  async_ack_o` |
| `async_data_i` | `input` | `input  logic [DATA_WIDTH-1:0] async_data_i` |

## Integration and Use

Never use a simple synchronizer for arbitrary multi-bit data. Keep both endpoint clocks running after reset release and obey all ready/busy outputs.

```systemverilog
cdc_2phase_dst #(
    .DATA_WIDTH(DATA_WIDTH),
    .SYNC_STAGES(SYNC_STAGES)
) u_cdc_2phase_dst (
    .rst_n_i(rst_n_i),
    .clk_i(clk_i),
    .data_o(data_o),
    .valid_o(valid_o),
    .ready_i(ready_i),
    .async_req_i(async_req_i),
    .async_ack_o(async_ack_o),
    .async_data_i(async_data_i)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
