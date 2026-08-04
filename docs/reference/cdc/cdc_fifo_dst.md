# cdc_fifo_dst

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/cdc/cdc_fifo.sv`](../../../rtl/cdc/cdc_fifo.sv) |
| Availability | Synthesizable RTL |

## Summary

Destination-side implementation of the asynchronous FIFO.

## Functional Behavior

Destination-side implementation of the asynchronous FIFO. It carries the declared control, event, or data contract through the stated synchronizer, handshake, or Gray-pointer mechanism. Endpoint reset discards in-flight data unless the page identifies an acknowledged warm-clear path.

## Suitable Applications

Use for reset release, asynchronous control/data transfer, asynchronous queues, event notification, and CDC recovery.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH       = 32` |
| `BUFFER_DEPTH` | `parameter int BUFFER_DEPTH     = 8` |
| `SYNC_STAGES` | `parameter int SYNC_STAGES      = 2` |
| `LOG_BUFFER_DEPTH` | `parameter int LOG_BUFFER_DEPTH = (BUFFER_DEPTH > 1) ? $clog2(BUFFER_DEPTH) : 1` |

## Interface Definition

```systemverilog
module cdc_fifo_dst #(
    parameter int DATA_WIDTH       = 32,
    parameter int BUFFER_DEPTH     = 8,
    parameter int SYNC_STAGES      = 2,
    parameter int LOG_BUFFER_DEPTH = (BUFFER_DEPTH > 1) ? $clog2(BUFFER_DEPTH) : 1
) (
    input  logic                                      clk_i,
    input  logic                                      rst_n_i,
    output logic [    DATA_WIDTH-1:0]                 data_o,
    output logic                                      valid_o,
    input  logic                                      ready_i,
    input  logic [  BUFFER_DEPTH-1:0][DATA_WIDTH-1:0] async_data_i,
    input  logic [LOG_BUFFER_DEPTH:0]                 async_wr_ptr_i,
    output logic [LOG_BUFFER_DEPTH:0]                 async_rd_ptr_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                                      clk_i` |
| `rst_n_i` | `input` | `input  logic                                      rst_n_i` |
| `data_o` | `output` | `output logic [    DATA_WIDTH-1:0]                 data_o` |
| `valid_o` | `output` | `output logic                                      valid_o` |
| `ready_i` | `input` | `input  logic                                      ready_i` |
| `async_data_i` | `input` | `input  logic [  BUFFER_DEPTH-1:0][DATA_WIDTH-1:0] async_data_i` |
| `async_wr_ptr_i` | `input` | `input  logic [LOG_BUFFER_DEPTH:0]                 async_wr_ptr_i` |
| `async_rd_ptr_o` | `output` | `output logic [LOG_BUFFER_DEPTH:0]                 async_rd_ptr_o` |

## Integration and Use

Never use a simple synchronizer for arbitrary multi-bit data. Keep both endpoint clocks running after reset release and obey all ready/busy outputs.

```systemverilog
cdc_fifo_dst #(
    .DATA_WIDTH(DATA_WIDTH),
    .BUFFER_DEPTH(BUFFER_DEPTH),
    .SYNC_STAGES(SYNC_STAGES),
    .LOG_BUFFER_DEPTH(LOG_BUFFER_DEPTH)
) u_cdc_fifo_dst (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_o(data_o),
    .valid_o(valid_o),
    .ready_i(ready_i),
    .async_data_i(async_data_i),
    .async_wr_ptr_i(async_wr_ptr_i),
    .async_rd_ptr_o(async_rd_ptr_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
