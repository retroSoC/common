# signal_tap

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/base/signal_helpers.sv`](../../../rtl/base/signal_helpers.sv) |
| Availability | Synthesizable RTL |

## Summary

Named combinational signal pass-through for observability.

## Functional Behavior

Named combinational signal pass-through for observability. It is a self-contained base primitive with the behavior and parameter checks implemented in the linked RTL source.

## Suitable Applications

Use as a structured building block for control, encoding, ECC, hashing, masking, replacement, or observability logic.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 1` |

## Interface Definition

```systemverilog
module signal_tap #(
    parameter int DATA_WIDTH = 1
) (
    input  logic [DATA_WIDTH-1:0] signal_i,
    output logic [DATA_WIDTH-1:0] signal_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `signal_i` | `input` | `input  logic [DATA_WIDTH-1:0] signal_i` |
| `signal_o` | `output` | `output logic [DATA_WIDTH-1:0] signal_o` |

## Integration and Use

Honor validity/error outputs and parameter constraints. Combinational cells do not provide timing isolation or CDC protection.

```systemverilog
signal_tap #(
    .DATA_WIDTH(DATA_WIDTH)
) u_signal_tap (
    .signal_i(signal_i),
    .signal_o(signal_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
