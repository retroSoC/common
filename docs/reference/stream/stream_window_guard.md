# stream_window_guard

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/stream/stream_control.sv`](../../../rtl/stream/stream_control.sv) |
| Availability | Synthesizable RTL |

## Summary

Limits outstanding stream requests with explicit retire accounting.

## Functional Behavior

Limits outstanding stream requests with explicit retire accounting. It follows the repository valid/ready rule: a payload transfers only when both signals are high in the same cycle, and a stalled valid payload remains stable.

## Suitable Applications

Use for elastic pipelines, stream routing, arbitration, backpressure, and response handling.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `MAX_INFLIGHT` | `parameter int MAX_INFLIGHT = 4` |
| `COUNT_WIDTH` | `parameter int COUNT_WIDTH  = $clog2(MAX_INFLIGHT + 1)` |

## Interface Definition

```systemverilog
module stream_window_guard #(
    parameter int MAX_INFLIGHT = 4,
    parameter int COUNT_WIDTH  = $clog2(MAX_INFLIGHT + 1)
) (
    input  logic                   clk_i,
    input  logic                   rst_n_i,
    input  logic                   flush_i,
    input  logic [COUNT_WIDTH-1:0] limit_i,
    input  logic                   submit_valid_i,
    output logic                   submit_ready_o,
    output logic                   forward_valid_o,
    input  logic                   forward_ready_i,
    input  logic                   retire_i,
    output logic [COUNT_WIDTH-1:0] used_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                   clk_i` |
| `rst_n_i` | `input` | `input  logic                   rst_n_i` |
| `flush_i` | `input` | `input  logic                   flush_i` |
| `limit_i` | `input` | `input  logic [COUNT_WIDTH-1:0] limit_i` |
| `submit_valid_i` | `input` | `input  logic                   submit_valid_i` |
| `submit_ready_o` | `output` | `output logic                   submit_ready_o` |
| `forward_valid_o` | `output` | `output logic                   forward_valid_o` |
| `forward_ready_i` | `input` | `input  logic                   forward_ready_i` |
| `retire_i` | `input` | `input  logic                   retire_i` |
| `used_o` | `output` | `output logic [COUNT_WIDTH-1:0] used_o` |

## Integration and Use

Observe vector sizing, selection encoding, and flush semantics in the declaration. Do not modify a valid payload while its corresponding ready is low.

```systemverilog
stream_window_guard #(
    .MAX_INFLIGHT(MAX_INFLIGHT),
    .COUNT_WIDTH(COUNT_WIDTH)
) u_stream_window_guard (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .flush_i(flush_i),
    .limit_i(limit_i),
    .submit_valid_i(submit_valid_i),
    .submit_ready_o(submit_ready_o),
    .forward_valid_o(forward_valid_o),
    .forward_ready_i(forward_ready_i),
    .retire_i(retire_i),
    .used_o(used_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
