# latest_value_stream

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/stream/stream_advanced.sv`](../../../rtl/stream/stream_advanced.sv) |
| Availability | Synthesizable RTL |

## Summary

Valid-only stream adapter retaining the newest pending value.

## Functional Behavior

Valid-only stream adapter retaining the newest pending value. It follows the repository valid/ready rule: a payload transfers only when both signals are high in the same cycle, and a stalled valid payload remains stable.

## Suitable Applications

Use for elastic pipelines, stream routing, arbitration, backpressure, and response handling.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 32` |

## Interface Definition

```systemverilog
module latest_value_stream #(
    parameter int DATA_WIDTH = 32
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  clear_i,
    input  logic                  in_valid_i,
    input  logic [DATA_WIDTH-1:0] in_data_i,
    output logic                  out_valid_o,
    input  logic                  out_ready_i,
    output logic [DATA_WIDTH-1:0] out_data_o,
    output logic                  busy_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                  clk_i` |
| `rst_n_i` | `input` | `input  logic                  rst_n_i` |
| `clear_i` | `input` | `input  logic                  clear_i` |
| `in_valid_i` | `input` | `input  logic                  in_valid_i` |
| `in_data_i` | `input` | `input  logic [DATA_WIDTH-1:0] in_data_i` |
| `out_valid_o` | `output` | `output logic                  out_valid_o` |
| `out_ready_i` | `input` | `input  logic                  out_ready_i` |
| `out_data_o` | `output` | `output logic [DATA_WIDTH-1:0] out_data_o` |
| `busy_o` | `output` | `output logic                  busy_o` |

## Integration and Use

Observe vector sizing, selection encoding, and flush semantics in the declaration. Do not modify a valid payload while its corresponding ready is low.

```systemverilog
latest_value_stream #(
    .DATA_WIDTH(DATA_WIDTH)
) u_latest_value_stream (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .clear_i(clear_i),
    .in_valid_i(in_valid_i),
    .in_data_i(in_data_i),
    .out_valid_o(out_valid_o),
    .out_ready_i(out_ready_i),
    .out_data_o(out_data_o),
    .busy_o(busy_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
