# hash_indicator_bank

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/base/hash_cells.sv`](../../../rtl/base/hash_cells.sv) |
| Availability | Synthesizable RTL |

## Summary

Multi-hash indicator-vector generator.

## Functional Behavior

Multi-hash indicator-vector generator. It is a self-contained base primitive with the behavior and parameter checks implemented in the linked RTL source.

## Suitable Applications

Use as a structured building block for control, encoding, ECC, hashing, masking, replacement, or observability logic.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int          DATA_WIDTH = 32` |
| `HASH_WIDTH` | `parameter int          HASH_WIDTH = 5` |
| `HASHES` | `parameter int          HASHES     = 3` |
| `ROUNDS` | `parameter int          ROUNDS     = 2` |
| `SEED` | `parameter logic [31:0] SEED       = 32'hC0DE_1234` |

## Interface Definition

```systemverilog
module hash_indicator_bank #(
    parameter int          DATA_WIDTH = 32,
    parameter int          HASH_WIDTH = 5,
    parameter int          HASHES     = 3,
    parameter int          ROUNDS     = 2,
    parameter logic [31:0] SEED       = 32'hC0DE_1234
) (
    input  logic [       DATA_WIDTH-1:0] data_i,
    output logic [(1 << HASH_WIDTH)-1:0] indicator_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `data_i` | `input` | `input  logic [       DATA_WIDTH-1:0] data_i` |
| `indicator_o` | `output` | `output logic [(1 << HASH_WIDTH)-1:0] indicator_o` |

## Integration and Use

Honor validity/error outputs and parameter constraints. Combinational cells do not provide timing isolation or CDC protection.

```systemverilog
hash_indicator_bank #(
    .DATA_WIDTH(DATA_WIDTH),
    .HASH_WIDTH(HASH_WIDTH),
    .HASHES(HASHES),
    .ROUNDS(ROUNDS),
    .SEED(SEED)
) u_hash_indicator_bank (
    .data_i(data_i),
    .indicator_o(indicator_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
