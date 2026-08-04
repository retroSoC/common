# prefix_ones_mask

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/base/mask_cells.sv`](../../../rtl/base/mask_cells.sv) |
| Availability | Synthesizable RTL |

## Summary

Low-order prefix-ones mask generator.

## Functional Behavior

Low-order prefix-ones mask generator. It is a self-contained base primitive with the behavior and parameter checks implemented in the linked RTL source.

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
module prefix_ones_mask #(
    parameter int WIDTH       = 32,
    parameter int INDEX_WIDTH = (WIDTH > 1) ? $clog2(WIDTH) : 1
) (
    input  logic [INDEX_WIDTH-1:0] position_i,
    output logic [      WIDTH-1:0] mask_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `position_i` | `input` | `input  logic [INDEX_WIDTH-1:0] position_i` |
| `mask_o` | `output` | `output logic [      WIDTH-1:0] mask_o` |

## Integration and Use

Honor validity/error outputs and parameter constraints. Combinational cells do not provide timing isolation or CDC protection.

```systemverilog
prefix_ones_mask #(
    .WIDTH(WIDTH),
    .INDEX_WIDTH(INDEX_WIDTH)
) u_prefix_ones_mask (
    .position_i(position_i),
    .mask_o(mask_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
