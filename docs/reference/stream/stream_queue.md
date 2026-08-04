# stream_queue

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/stream/stream_advanced.sv`](../../../rtl/stream/stream_advanced.sv) |
| Availability | Synthesizable RTL |

## Summary

Parameterized valid/ready queue with optional fall-through.

## Functional Behavior

Parameterized valid/ready queue with optional fall-through. It follows the repository valid/ready rule: a payload transfers only when both signals are high in the same cycle, and a stalled valid payload remains stable.

## Suitable Applications

Use for elastic pipelines, stream routing, arbitration, backpressure, and response handling.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH   = 32` |
| `DEPTH` | `parameter int DEPTH        = 4` |
| `FALL_THROUGH` | `parameter bit FALL_THROUGH = 1'b1` |
| `PTR_WIDTH` | `parameter int PTR_WIDTH    = (DEPTH > 1) ? $clog2(DEPTH) : 1` |
| `COUNT_WIDTH` | `parameter int COUNT_WIDTH  = $clog2(DEPTH + 1)` |

## Interface Definition

```systemverilog
module stream_queue #(
    parameter int DATA_WIDTH   = 32,
    parameter int DEPTH        = 4,
    parameter bit FALL_THROUGH = 1'b1,
    parameter int PTR_WIDTH    = (DEPTH > 1) ? $clog2(DEPTH) : 1,
    parameter int COUNT_WIDTH  = $clog2(DEPTH + 1)
) (
    input  logic                   clk_i,
    input  logic                   rst_n_i,
    input  logic                   flush_i,
    input  logic                   in_valid_i,
    output logic                   in_ready_o,
    input  logic [ DATA_WIDTH-1:0] in_data_i,
    output logic                   out_valid_o,
    input  logic                   out_ready_i,
    output logic [ DATA_WIDTH-1:0] out_data_o,
    output logic [COUNT_WIDTH-1:0] usage_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                   clk_i` |
| `rst_n_i` | `input` | `input  logic                   rst_n_i` |
| `flush_i` | `input` | `input  logic                   flush_i` |
| `in_valid_i` | `input` | `input  logic                   in_valid_i` |
| `in_ready_o` | `output` | `output logic                   in_ready_o` |
| `in_data_i` | `input` | `input  logic [ DATA_WIDTH-1:0] in_data_i` |
| `out_valid_o` | `output` | `output logic                   out_valid_o` |
| `out_ready_i` | `input` | `input  logic                   out_ready_i` |
| `out_data_o` | `output` | `output logic [ DATA_WIDTH-1:0] out_data_o` |
| `usage_o` | `output` | `output logic [COUNT_WIDTH-1:0] usage_o` |

## Integration and Use

Observe vector sizing, selection encoding, and flush semantics in the declaration. Do not modify a valid payload while its corresponding ready is low.

```systemverilog
stream_queue #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH),
    .FALL_THROUGH(FALL_THROUGH),
    .PTR_WIDTH(PTR_WIDTH),
    .COUNT_WIDTH(COUNT_WIDTH)
) u_stream_queue (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .flush_i(flush_i),
    .in_valid_i(in_valid_i),
    .in_ready_o(in_ready_o),
    .in_data_i(in_data_i),
    .out_valid_o(out_valid_o),
    .out_ready_i(out_ready_i),
    .out_data_o(out_data_o),
    .usage_o(usage_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
