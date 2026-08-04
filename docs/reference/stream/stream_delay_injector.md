# stream_delay_injector

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/stream/stream_advanced.sv`](../../../rtl/stream/stream_advanced.sv) |
| Availability | Synthesizable RTL |

## Summary

Controlled stream delay injector for verification and stress.

## Functional Behavior

Controlled stream delay injector for verification and stress. It follows the repository valid/ready rule: a payload transfers only when both signals are high in the same cycle, and a stalled valid payload remains stable.

## Suitable Applications

Use for elastic pipelines, stream routing, arbitration, backpressure, and response handling.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int          DATA_WIDTH   = 32` |
| `FIXED_DELAY` | `parameter int          FIXED_DELAY  = 1` |
| `RANDOM_DELAY` | `parameter bit          RANDOM_DELAY = 1'b0` |
| `RANDOM_SEED` | `parameter logic [15:0] RANDOM_SEED  = 16'h1` |
| `RANDOM_POLY` | `parameter logic [15:0] RANDOM_POLY  = 16'hB400` |

## Interface Definition

```systemverilog
module stream_delay_injector #(
    parameter int          DATA_WIDTH   = 32,
    parameter int          FIXED_DELAY  = 1,
    parameter bit          RANDOM_DELAY = 1'b0,
    parameter logic [15:0] RANDOM_SEED  = 16'h1,
    parameter logic [15:0] RANDOM_POLY  = 16'hB400
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  clear_i,
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
| `clk_i` | `input` | `input  logic                  clk_i` |
| `rst_n_i` | `input` | `input  logic                  rst_n_i` |
| `clear_i` | `input` | `input  logic                  clear_i` |
| `in_valid_i` | `input` | `input  logic                  in_valid_i` |
| `in_ready_o` | `output` | `output logic                  in_ready_o` |
| `in_data_i` | `input` | `input  logic [DATA_WIDTH-1:0] in_data_i` |
| `out_valid_o` | `output` | `output logic                  out_valid_o` |
| `out_ready_i` | `input` | `input  logic                  out_ready_i` |
| `out_data_o` | `output` | `output logic [DATA_WIDTH-1:0] out_data_o` |

## Integration and Use

Observe vector sizing, selection encoding, and flush semantics in the declaration. Do not modify a valid payload while its corresponding ready is low.

```systemverilog
stream_delay_injector #(
    .DATA_WIDTH(DATA_WIDTH),
    .FIXED_DELAY(FIXED_DELAY),
    .RANDOM_DELAY(RANDOM_DELAY),
    .RANDOM_SEED(RANDOM_SEED),
    .RANDOM_POLY(RANDOM_POLY)
) u_stream_delay_injector (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .clear_i(clear_i),
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
