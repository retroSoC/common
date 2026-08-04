# onehot_check

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/base/bit_ops.sv`](../../../rtl/base/bit_ops.sv) |
| Availability | Synthesizable RTL |

## Summary

One-hot validity checker with optional all-zero acceptance.

## Functional Behavior

One-hot validity checker with optional all-zero acceptance. It is a self-contained base primitive with the behavior and parameter checks implemented in the linked RTL source.

## Suitable Applications

Use as a structured building block for control, encoding, ECC, hashing, masking, replacement, or observability logic.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `WIDTH` | `parameter int WIDTH      = 32` |
| `ALLOW_ZERO` | `parameter bit ALLOW_ZERO = 1'b0` |

## Interface Definition

```systemverilog
module onehot_check #(
    parameter int WIDTH      = 32,
    parameter bit ALLOW_ZERO = 1'b0
) (
    input  logic [WIDTH-1:0] value_i,
    output logic             valid_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `value_i` | `input` | `input  logic [WIDTH-1:0] value_i` |
| `valid_o` | `output` | `output logic             valid_o` |

## Integration and Use

Honor validity/error outputs and parameter constraints. Combinational cells do not provide timing isolation or CDC protection.

```systemverilog
onehot_check #(
    .WIDTH(WIDTH),
    .ALLOW_ZERO(ALLOW_ZERO)
) u_onehot_check (
    .value_i(value_i),
    .valid_o(valid_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
