# memory_response_bridge

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/stream/stream_advanced.sv`](../../../rtl/stream/stream_advanced.sv) |
| Availability | Synthesizable RTL |

## Summary

Response-order bridge between memory and stream interfaces.

## Functional Behavior

Response-order bridge between memory and stream interfaces. It follows the repository valid/ready rule: a payload transfers only when both signals are high in the same cycle, and a stalled valid payload remains stable.

## Suitable Applications

Use for elastic pipelines, stream routing, arbitration, backpressure, and response handling.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `REQUEST_WIDTH` | `parameter int REQUEST_WIDTH  = 32` |
| `RESPONSE_WIDTH` | `parameter int RESPONSE_WIDTH = 32` |
| `RESPONSE_DEPTH` | `parameter int RESPONSE_DEPTH = 2` |
| `COUNT_WIDTH` | `parameter int COUNT_WIDTH    = $clog2(RESPONSE_DEPTH + 1)` |

## Interface Definition

```systemverilog
module memory_response_bridge #(
    parameter int REQUEST_WIDTH  = 32,
    parameter int RESPONSE_WIDTH = 32,
    parameter int RESPONSE_DEPTH = 2,
    parameter int COUNT_WIDTH    = $clog2(RESPONSE_DEPTH + 1)
) (
    input  logic                      clk_i,
    input  logic                      rst_n_i,
    input  logic                      clear_i,
    input  logic [ REQUEST_WIDTH-1:0] request_i,
    input  logic                      request_valid_i,
    output logic                      request_ready_o,
    output logic [ REQUEST_WIDTH-1:0] memory_request_o,
    output logic                      memory_request_valid_o,
    input  logic                      memory_request_ready_i,
    input  logic [RESPONSE_WIDTH-1:0] memory_response_i,
    input  logic                      memory_response_valid_i,
    output logic [RESPONSE_WIDTH-1:0] response_o,
    output logic                      response_valid_o,
    input  logic                      response_ready_i
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                      clk_i` |
| `rst_n_i` | `input` | `input  logic                      rst_n_i` |
| `clear_i` | `input` | `input  logic                      clear_i` |
| `request_i` | `input` | `input  logic [ REQUEST_WIDTH-1:0] request_i` |
| `request_valid_i` | `input` | `input  logic                      request_valid_i` |
| `request_ready_o` | `output` | `output logic                      request_ready_o` |
| `memory_request_o` | `output` | `output logic [ REQUEST_WIDTH-1:0] memory_request_o` |
| `memory_request_valid_o` | `output` | `output logic                      memory_request_valid_o` |
| `memory_request_ready_i` | `input` | `input  logic                      memory_request_ready_i` |
| `memory_response_i` | `input` | `input  logic [RESPONSE_WIDTH-1:0] memory_response_i` |
| `memory_response_valid_i` | `input` | `input  logic                      memory_response_valid_i` |
| `response_o` | `output` | `output logic [RESPONSE_WIDTH-1:0] response_o` |
| `response_valid_o` | `output` | `output logic                      response_valid_o` |
| `response_ready_i` | `input` | `input  logic                      response_ready_i` |

## Integration and Use

Observe vector sizing, selection encoding, and flush semantics in the declaration. Do not modify a valid payload while its corresponding ready is low.

```systemverilog
memory_response_bridge #(
    .REQUEST_WIDTH(REQUEST_WIDTH),
    .RESPONSE_WIDTH(RESPONSE_WIDTH),
    .RESPONSE_DEPTH(RESPONSE_DEPTH),
    .COUNT_WIDTH(COUNT_WIDTH)
) u_memory_response_bridge (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .clear_i(clear_i),
    .request_i(request_i),
    .request_valid_i(request_valid_i),
    .request_ready_o(request_ready_o),
    .memory_request_o(memory_request_o),
    .memory_request_valid_o(memory_request_valid_o),
    .memory_request_ready_i(memory_request_ready_i),
    .memory_response_i(memory_response_i),
    .memory_response_valid_i(memory_response_valid_i),
    .response_o(response_o),
    .response_valid_o(response_valid_o),
    .response_ready_i(response_ready_i)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
