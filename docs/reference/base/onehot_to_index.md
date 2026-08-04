# onehot_to_index

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/base/bit_ops.sv`](../../../rtl/base/bit_ops.sv) |
| Availability | Synthesizable RTL |

## Summary

One-hot vector to index converter with validity output.

## Functional Behavior

One-hot vector to index converter with validity output. It is a self-contained base primitive with the behavior and parameter checks implemented in the linked RTL source.

## Suitable Applications

Use as a structured building block for control, encoding, ECC, hashing, masking, replacement, or observability logic.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `WIDTH` | `parameter int WIDTH       = 32` |
| `INDEX_WIDTH` | `parameter int INDEX_WIDTH = (WIDTH > 1) ? $clog2(WIDTH) : 1` |

## Interface Definition

```systemverilog
module onehot_to_index #(
    parameter int WIDTH       = 32,
    parameter int INDEX_WIDTH = (WIDTH > 1) ? $clog2(WIDTH) : 1
) (
    input  logic [      WIDTH-1:0] value_i,
    output logic [INDEX_WIDTH-1:0] index_o,
    output logic                   valid_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `value_i` | `input` | `input  logic [      WIDTH-1:0] value_i` |
| `index_o` | `output` | `output logic [INDEX_WIDTH-1:0] index_o` |
| `valid_o` | `output` | `output logic                   valid_o` |

## Integration and Use

Honor validity/error outputs and parameter constraints. Combinational cells do not provide timing isolation or CDC protection.

```systemverilog
onehot_to_index #(
    .WIDTH(WIDTH),
    .INDEX_WIDTH(INDEX_WIDTH)
) u_onehot_to_index (
    .value_i(value_i),
    .index_o(index_o),
    .valid_o(valid_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
