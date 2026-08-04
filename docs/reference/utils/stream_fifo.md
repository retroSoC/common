# stream_fifo

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/utils/fifo.sv`](../../../rtl/utils/fifo.sv) |
| Availability | Synthesizable RTL |

## Summary

Legacy valid/ready wrapper around the synchronous FIFO.

## Functional Behavior

Legacy valid/ready wrapper around the synchronous FIFO. Its exact parameters and ports are reproduced below from the implementation declaration.

## Suitable Applications

Use as a small reusable datapath, state, coding, delay, or verification primitive.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH       = 32` |
| `BUFFER_DEPTH` | `parameter int BUFFER_DEPTH     = 8` |
| `LOG_BUFFER_DEPTH` | `parameter int LOG_BUFFER_DEPTH = (BUFFER_DEPTH > 1) ? $clog2(BUFFER_DEPTH) : 1` |

## Interface Definition

```systemverilog
module stream_fifo #(
    parameter int DATA_WIDTH       = 32,
    parameter int BUFFER_DEPTH     = 8,
    parameter int LOG_BUFFER_DEPTH = (BUFFER_DEPTH > 1) ? $clog2(BUFFER_DEPTH) : 1
) (
    input  logic                      clk_i,
    input  logic                      rst_n_i,
    input  logic                      flush_i,
    output logic                      full_o,
    output logic                      empty_o,
    output logic [LOG_BUFFER_DEPTH:0] cnt_o,
    input  logic [    DATA_WIDTH-1:0] dat_i,
    input  logic                      push_i,
    output logic [    DATA_WIDTH-1:0] dat_o,
    input  logic                      pop_i
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                      clk_i` |
| `rst_n_i` | `input` | `input  logic                      rst_n_i` |
| `flush_i` | `input` | `input  logic                      flush_i` |
| `full_o` | `output` | `output logic                      full_o` |
| `empty_o` | `output` | `output logic                      empty_o` |
| `cnt_o` | `output` | `output logic [LOG_BUFFER_DEPTH:0] cnt_o` |
| `dat_i` | `input` | `input  logic [    DATA_WIDTH-1:0] dat_i` |
| `push_i` | `input` | `input  logic                      push_i` |
| `dat_o` | `output` | `output logic [    DATA_WIDTH-1:0] dat_o` |
| `pop_i` | `input` | `input  logic                      pop_i` |

## Integration and Use

Keep parameter values within RTL assertions and add required clocking, reset, or CDC protection at the caller boundary.

```systemverilog
stream_fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .BUFFER_DEPTH(BUFFER_DEPTH),
    .LOG_BUFFER_DEPTH(LOG_BUFFER_DEPTH)
) u_stream_fifo (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .flush_i(flush_i),
    .full_o(full_o),
    .empty_o(empty_o),
    .cnt_o(cnt_o),
    .dat_i(dat_i),
    .push_i(push_i),
    .dat_o(dat_o),
    .pop_i(pop_i)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
