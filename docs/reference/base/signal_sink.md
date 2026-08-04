# signal_sink

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/base/signal_helpers.sv`](../../../rtl/base/signal_helpers.sv) |
| Availability | Synthesizable RTL |

## Summary

Intentional unused-signal terminator.

## Functional Behavior

Intentional unused-signal terminator. It is a self-contained base primitive with the behavior and parameter checks implemented in the linked RTL source.

## Suitable Applications

Use as a structured building block for control, encoding, ECC, hashing, masking, replacement, or observability logic.

## Parameters

This unit has no configurable parameters.

## Interface Definition

```systemverilog
module signal_sink (
    input logic signal_i
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `signal_i` | `input` | `input logic signal_i` |

## Integration and Use

Honor validity/error outputs and parameter constraints. Combinational cells do not provide timing isolation or CDC protection.

```systemverilog
signal_sink u_signal_sink (
    .signal_i(signal_i)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
