# stream_selector

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/stream/stream_cells.sv`](../../../rtl/stream/stream_cells.sv) |
| Availability | Synthesizable RTL |

## Summary

Selects one of several valid/ready inputs.

## Functional Behavior

Selects one of several valid/ready inputs. It follows the repository valid/ready rule: a payload transfers only when both signals are high in the same cycle, and a stalled valid payload remains stable.

## Suitable Applications

Use for elastic pipelines, stream routing, arbitration, backpressure, and response handling.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH   = 32` |
| `PORTS` | `parameter int PORTS        = 4` |
| `SELECT_WIDTH` | `parameter int SELECT_WIDTH = (PORTS > 1) ? $clog2(PORTS) : 1` |

## Interface Definition

```systemverilog
module stream_selector #(
    parameter int DATA_WIDTH   = 32,
    parameter int PORTS        = 4,
    parameter int SELECT_WIDTH = (PORTS > 1) ? $clog2(PORTS) : 1
) (
    input  logic [SELECT_WIDTH-1:0]                 select_i,
    input  logic [       PORTS-1:0]                 in_valid_i,
    output logic [       PORTS-1:0]                 in_ready_o,
    input  logic [       PORTS-1:0][DATA_WIDTH-1:0] in_data_i,
    output logic                                    out_valid_o,
    input  logic                                    out_ready_i,
    output logic [  DATA_WIDTH-1:0]                 out_data_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `select_i` | `input` | `input  logic [SELECT_WIDTH-1:0]                 select_i` |
| `in_valid_i` | `input` | `input  logic [       PORTS-1:0]                 in_valid_i` |
| `in_ready_o` | `output` | `output logic [       PORTS-1:0]                 in_ready_o` |
| `in_data_i` | `input` | `input  logic [       PORTS-1:0][DATA_WIDTH-1:0] in_data_i` |
| `out_valid_o` | `output` | `output logic                                    out_valid_o` |
| `out_ready_i` | `input` | `input  logic                                    out_ready_i` |
| `out_data_o` | `output` | `output logic [  DATA_WIDTH-1:0]                 out_data_o` |

## Integration and Use

Observe vector sizing, selection encoding, and flush semantics in the declaration. Do not modify a valid payload while its corresponding ready is low.

```systemverilog
stream_selector #(
    .DATA_WIDTH(DATA_WIDTH),
    .PORTS(PORTS),
    .SELECT_WIDTH(SELECT_WIDTH)
) u_stream_selector (
    .select_i(select_i),
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
