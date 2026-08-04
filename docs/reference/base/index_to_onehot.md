# index_to_onehot

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/base/mask_cells.sv`](../../../rtl/base/mask_cells.sv) |
| Availability | Synthesizable RTL |

## Summary

Bounded index-to-one-hot decoder.

## Functional Behavior

Bounded index-to-one-hot decoder. It is a self-contained base primitive with the behavior and parameter checks implemented in the linked RTL source.

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
module index_to_onehot #(
    parameter int WIDTH       = 32,
    parameter int INDEX_WIDTH = (WIDTH > 1) ? $clog2(WIDTH) : 1
) (
    input  logic [INDEX_WIDTH-1:0] index_i,
    input  logic                   enable_i,
    output logic [      WIDTH-1:0] onehot_o,
    output logic                   valid_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `index_i` | `input` | `input  logic [INDEX_WIDTH-1:0] index_i` |
| `enable_i` | `input` | `input  logic                   enable_i` |
| `onehot_o` | `output` | `output logic [      WIDTH-1:0] onehot_o` |
| `valid_o` | `output` | `output logic                   valid_o` |

## Integration and Use

Honor validity/error outputs and parameter constraints. Combinational cells do not provide timing isolation or CDC protection.

```systemverilog
index_to_onehot #(
    .WIDTH(WIDTH),
    .INDEX_WIDTH(INDEX_WIDTH)
) u_index_to_onehot (
    .index_i(index_i),
    .enable_i(enable_i),
    .onehot_o(onehot_o),
    .valid_o(valid_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
