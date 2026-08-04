# stream_discard_gate

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/stream/stream_control.sv`](../../../rtl/stream/stream_control.sv) |
| Availability | Synthesizable RTL |

## Summary

Consumes input transfers while discard is asserted.

## Functional Behavior

Consumes input transfers while discard is asserted. It follows the repository valid/ready rule: a payload transfers only when both signals are high in the same cycle, and a stalled valid payload remains stable.

## Suitable Applications

Use for elastic pipelines, stream routing, arbitration, backpressure, and response handling.

## Parameters

This unit has no configurable parameters.

## Interface Definition

```systemverilog
module stream_discard_gate (
    input  logic in_valid_i,
    output logic in_ready_o,
    input  logic discard_i,
    output logic out_valid_o,
    input  logic out_ready_i
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `in_valid_i` | `input` | `input  logic in_valid_i` |
| `in_ready_o` | `output` | `output logic in_ready_o` |
| `discard_i` | `input` | `input  logic discard_i` |
| `out_valid_o` | `output` | `output logic out_valid_o` |
| `out_ready_i` | `input` | `input  logic out_ready_i` |

## Integration and Use

Observe vector sizing, selection encoding, and flush semantics in the declaration. Do not modify a valid payload while its corresponding ready is low.

```systemverilog
stream_discard_gate u_stream_discard_gate (
    .in_valid_i(in_valid_i),
    .in_ready_o(in_ready_o),
    .discard_i(discard_i),
    .out_valid_o(out_valid_o),
    .out_ready_i(out_ready_i)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
