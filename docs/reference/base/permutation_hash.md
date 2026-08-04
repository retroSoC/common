# permutation_hash

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/base/hash_cells.sv`](../../../rtl/base/hash_cells.sv) |
| Availability | Synthesizable RTL |

## Summary

Deterministic non-cryptographic bit-mixing hash.

## Functional Behavior

Deterministic non-cryptographic bit-mixing hash. It is a self-contained base primitive with the behavior and parameter checks implemented in the linked RTL source.

## Suitable Applications

Use as a structured building block for control, encoding, ECC, hashing, masking, replacement, or observability logic.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int          DATA_WIDTH  = 32` |
| `HASH_WIDTH` | `parameter int          HASH_WIDTH  = 5` |
| `ROUNDS` | `parameter int          ROUNDS      = 2` |
| `PERMUTE_KEY` | `parameter logic [31:0] PERMUTE_KEY = 32'h11C0_FFEE` |
| `MIX_KEY` | `parameter logic [31:0] MIX_KEY     = 32'h7A31_9B45` |

## Interface Definition

```systemverilog
module permutation_hash #(
    parameter int          DATA_WIDTH  = 32,
    parameter int          HASH_WIDTH  = 5,
    parameter int          ROUNDS      = 2,
    parameter logic [31:0] PERMUTE_KEY = 32'h11C0_FFEE,
    parameter logic [31:0] MIX_KEY     = 32'h7A31_9B45
) (
    input  logic [       DATA_WIDTH-1:0] data_i,
    output logic [       HASH_WIDTH-1:0] hash_o,
    output logic [(1 << HASH_WIDTH)-1:0] indicator_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `data_i` | `input` | `input  logic [       DATA_WIDTH-1:0] data_i` |
| `hash_o` | `output` | `output logic [       HASH_WIDTH-1:0] hash_o` |
| `indicator_o` | `output` | `output logic [(1 << HASH_WIDTH)-1:0] indicator_o` |

## Integration and Use

Honor validity/error outputs and parameter constraints. Combinational cells do not provide timing isolation or CDC protection.

```systemverilog
permutation_hash #(
    .DATA_WIDTH(DATA_WIDTH),
    .HASH_WIDTH(HASH_WIDTH),
    .ROUNDS(ROUNDS),
    .PERMUTE_KEY(PERMUTE_KEY),
    .MIX_KEY(MIX_KEY)
) u_permutation_hash (
    .data_i(data_i),
    .hash_o(hash_o),
    .indicator_o(indicator_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
