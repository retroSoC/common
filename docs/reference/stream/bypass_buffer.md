# bypass_buffer

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/stream/stream_cells.sv`](../../../rtl/stream/stream_cells.sv) |
| Availability | Synthesizable RTL |

## Summary

Combinational valid/ready stream pass-through.

## Functional Behavior

Combinational valid/ready stream pass-through. It follows the repository valid/ready rule: a payload transfers only when both signals are high in the same cycle, and a stalled valid payload remains stable.

## Suitable Applications

Use for elastic pipelines, stream routing, arbitration, backpressure, and response handling.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 32` |

## Interface Definition

```systemverilog
module bypass_buffer #(
    parameter int DATA_WIDTH = 32
) (
    input  logic                  flush_i,
    input  logic                  in_valid_i,
    output logic                  in_ready_o,
    input  logic [DATA_WIDTH-1:0] in_data_i,
    output logic                  out_valid_o,
    input  logic                  out_ready_i,
    output logic [DATA_WIDTH-1:0] out_data_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `flush_i` | `input` | `input  logic                  flush_i` |
| `in_valid_i` | `input` | `input  logic                  in_valid_i` |
| `in_ready_o` | `output` | `output logic                  in_ready_o` |
| `in_data_i` | `input` | `input  logic [DATA_WIDTH-1:0] in_data_i` |
| `out_valid_o` | `output` | `output logic                  out_valid_o` |
| `out_ready_i` | `input` | `input  logic                  out_ready_i` |
| `out_data_o` | `output` | `output logic [DATA_WIDTH-1:0] out_data_o` |

## Integration and Use

Observe vector sizing, selection encoding, and flush semantics in the declaration. Do not modify a valid payload while its corresponding ready is low.

```systemverilog
bypass_buffer #(
    .DATA_WIDTH(DATA_WIDTH)
) u_bypass_buffer (
    .flush_i(flush_i),
    .in_valid_i(in_valid_i),
    .in_ready_o(in_ready_o),
    .in_data_i(in_data_i),
    .out_valid_o(out_valid_o),
    .out_ready_i(out_ready_i),
    .out_data_o(out_data_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
