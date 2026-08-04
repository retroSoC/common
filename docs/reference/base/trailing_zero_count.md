# trailing_zero_count

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/base/mask_cells.sv`](../../../rtl/base/mask_cells.sv) |
| Availability | Synthesizable RTL |

## Summary

Combinational trailing-zero counter with all-zero indication.

## Functional Behavior

Combinational trailing-zero counter with all-zero indication. It is a self-contained base primitive with the behavior and parameter checks implemented in the linked RTL source.

## Suitable Applications

Use as a structured building block for control, encoding, ECC, hashing, masking, replacement, or observability logic.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `WIDTH` | `parameter int WIDTH       = 32` |
| `COUNT_WIDTH` | `parameter int COUNT_WIDTH = $clog2(WIDTH + 1)` |

## Interface Definition

```systemverilog
module trailing_zero_count #(
    parameter int WIDTH       = 32,
    parameter int COUNT_WIDTH = $clog2(WIDTH + 1)
) (
    input  logic [      WIDTH-1:0] value_i,
    output logic [COUNT_WIDTH-1:0] count_o,
    output logic                   all_zero_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `value_i` | `input` | `input  logic [      WIDTH-1:0] value_i` |
| `count_o` | `output` | `output logic [COUNT_WIDTH-1:0] count_o` |
| `all_zero_o` | `output` | `output logic                   all_zero_o` |

## Integration and Use

Honor validity/error outputs and parameter constraints. Combinational cells do not provide timing isolation or CDC protection.

```systemverilog
trailing_zero_count #(
    .WIDTH(WIDTH),
    .COUNT_WIDTH(COUNT_WIDTH)
) u_trailing_zero_count (
    .value_i(value_i),
    .count_o(count_o),
    .all_zero_o(all_zero_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
