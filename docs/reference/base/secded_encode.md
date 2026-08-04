# secded_encode

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/base/ecc_secded.sv`](../../../rtl/base/ecc_secded.sv) |
| Availability | Synthesizable RTL |

## Summary

Extended-Hamming SECDED encoder.

## Functional Behavior

Places data in the shared SECDED layout, generates Hamming parity positions, and appends overall parity for single-error correction and double-error detection.

## Suitable Applications

Use before writing protected memories or sending protected link data.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 64` |

## Interface Definition

```systemverilog
module secded_encode #(
    parameter int DATA_WIDTH = 64
) (
    input  logic [                                            DATA_WIDTH-1:0] data_i,
    output logic [DATA_WIDTH+secded_layout_pkg::check_bits_for(DATA_WIDTH):0] code_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `data_i` | `input` | `input  logic [                                            DATA_WIDTH-1:0] data_i` |
| `code_o` | `output` | `output logic [DATA_WIDTH+secded_layout_pkg::check_bits_for(DATA_WIDTH):0] code_o` |

## Integration and Use

Pair only with `secded_decode` built from the same parameters and layout package.

```systemverilog
secded_encode #(
    .DATA_WIDTH(DATA_WIDTH)
) u_secded_encode (
    .data_i(data_i),
    .code_o(code_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
