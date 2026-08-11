# axi4_stream_regslice

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/stream/axi4_stream_regslice.sv`](../../../rtl/stream/axi4_stream_regslice.sv) |
| Availability | Synthesizable RTL |

## Summary

Elastic AXI4-Stream register slice.

## Functional Behavior

Elastic AXI4-Stream register slice. It follows the repository valid/ready rule: a payload transfers only when both signals are high in the same cycle, and a stalled valid payload remains stable.

## Suitable Applications

Use for elastic pipelines, stream routing, arbitration, backpressure, and response handling.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 32` |
| `ID_WIDTH` | `parameter int ID_WIDTH   = 1` |
| `DEST_WIDTH` | `parameter int DEST_WIDTH = 1` |
| `USER_WIDTH` | `parameter int USER_WIDTH = 1` |
| `BYPASS` | `parameter bit BYPASS     = 1'b0` |

## Interface Definition

```systemverilog
module axi4_stream_regslice #(
    parameter int DATA_WIDTH = 32,
    parameter int ID_WIDTH   = 1,
    parameter int DEST_WIDTH = 1,
    parameter int USER_WIDTH = 1,
    parameter bit BYPASS     = 1'b0
) (
    input logic                 clk_i,
    input logic                 rst_n_i,
    input logic                 flush_i,
          axi4_stream_if.sink   sink,
          axi4_stream_if.source source
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input logic                 clk_i` |
| `rst_n_i` | `input` | `input logic                 rst_n_i` |
| `flush_i` | `input` | `input logic                 flush_i` |

## Integration and Use

Observe vector sizing, selection encoding, and flush semantics in the declaration. Do not modify a valid payload while its corresponding ready is low.

```systemverilog
axi4_stream_regslice #(
    .DATA_WIDTH(DATA_WIDTH),
    .ID_WIDTH(ID_WIDTH),
    .DEST_WIDTH(DEST_WIDTH),
    .USER_WIDTH(USER_WIDTH),
    .BYPASS(BYPASS)
) u_axi4_stream_regslice (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .flush_i(flush_i)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
