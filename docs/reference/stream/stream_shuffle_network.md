# stream_shuffle_network

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/stream/stream_advanced.sv`](../../../rtl/stream/stream_advanced.sv) |
| Availability | Synthesizable RTL |

## Summary

Deterministic stream-lane permutation network.

## Functional Behavior

Deterministic stream-lane permutation network. It follows the repository valid/ready rule: a payload transfers only when both signals are high in the same cycle, and a stalled valid payload remains stable.

## Suitable Applications

Use for elastic pipelines, stream routing, arbitration, backpressure, and response handling.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH   = 32` |
| `INPUTS` | `parameter int INPUTS       = 4` |
| `OUTPUTS` | `parameter int OUTPUTS      = 4` |
| `TARGET_WIDTH` | `parameter int TARGET_WIDTH = (OUTPUTS > 1) ? $clog2(OUTPUTS) : 1` |
| `SOURCE_WIDTH` | `parameter int SOURCE_WIDTH = (INPUTS > 1) ? $clog2(INPUTS) : 1` |

## Interface Definition

```systemverilog
module stream_shuffle_network #(
    parameter int DATA_WIDTH   = 32,
    parameter int INPUTS       = 4,
    parameter int OUTPUTS      = 4,
    parameter int TARGET_WIDTH = (OUTPUTS > 1) ? $clog2(OUTPUTS) : 1,
    parameter int SOURCE_WIDTH = (INPUTS > 1) ? $clog2(INPUTS) : 1
) (
    input  logic                                 clk_i,
    input  logic                                 rst_n_i,
    input  logic                                 clear_i,
    input  logic [ INPUTS-1:0]                   in_valid_i,
    output logic [ INPUTS-1:0]                   in_ready_o,
    input  logic [ INPUTS-1:0][  DATA_WIDTH-1:0] in_data_i,
    input  logic [ INPUTS-1:0][TARGET_WIDTH-1:0] target_i,
    output logic [OUTPUTS-1:0]                   out_valid_o,
    input  logic [OUTPUTS-1:0]                   out_ready_i,
    output logic [OUTPUTS-1:0][  DATA_WIDTH-1:0] out_data_o,
    output logic [OUTPUTS-1:0][SOURCE_WIDTH-1:0] source_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                                 clk_i` |
| `rst_n_i` | `input` | `input  logic                                 rst_n_i` |
| `clear_i` | `input` | `input  logic                                 clear_i` |
| `in_valid_i` | `input` | `input  logic [ INPUTS-1:0]                   in_valid_i` |
| `in_ready_o` | `output` | `output logic [ INPUTS-1:0]                   in_ready_o` |
| `in_data_i` | `input` | `input  logic [ INPUTS-1:0][  DATA_WIDTH-1:0] in_data_i` |
| `target_i` | `input` | `input  logic [ INPUTS-1:0][TARGET_WIDTH-1:0] target_i` |
| `out_valid_o` | `output` | `output logic [OUTPUTS-1:0]                   out_valid_o` |
| `out_ready_i` | `input` | `input  logic [OUTPUTS-1:0]                   out_ready_i` |
| `out_data_o` | `output` | `output logic [OUTPUTS-1:0][  DATA_WIDTH-1:0] out_data_o` |
| `source_o` | `output` | `output logic [OUTPUTS-1:0][SOURCE_WIDTH-1:0] source_o` |

## Integration and Use

Observe vector sizing, selection encoding, and flush semantics in the declaration. Do not modify a valid payload while its corresponding ready is low.

```systemverilog
stream_shuffle_network #(
    .DATA_WIDTH(DATA_WIDTH),
    .INPUTS(INPUTS),
    .OUTPUTS(OUTPUTS),
    .TARGET_WIDTH(TARGET_WIDTH),
    .SOURCE_WIDTH(SOURCE_WIDTH)
) u_stream_shuffle_network (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .clear_i(clear_i),
    .in_valid_i(in_valid_i),
    .in_ready_o(in_ready_o),
    .in_data_i(in_data_i),
    .target_i(target_i),
    .out_valid_o(out_valid_o),
    .out_ready_i(out_ready_i),
    .out_data_o(out_data_o),
    .source_o(source_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
