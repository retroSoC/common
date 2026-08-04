# secded_decode

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/base/ecc_secded.sv`](../../../rtl/base/ecc_secded.sv) |
| Availability | Synthesizable RTL |

## Summary

Extended-Hamming SECDED decoder, corrector, and error classifier.

## Functional Behavior

Computes a Hamming syndrome and overall parity, corrects a correctable single-bit fault, reports an overall-parity-only error, and flags uncorrectable double errors without changing the codeword.

## Suitable Applications

Use on protected memory reads and protected interconnect payloads.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 64` |

## Interface Definition

```systemverilog
module secded_decode #(
    parameter int DATA_WIDTH = 64
) (
    input logic [DATA_WIDTH+secded_layout_pkg::check_bits_for(DATA_WIDTH):0] code_i,
    output logic [DATA_WIDTH-1:0] data_o,
    output logic [secded_layout_pkg::check_bits_for(DATA_WIDTH)-1:0] syndrome_o,
    output logic corrected_o,
    output logic overall_parity_error_o,
    output logic uncorrectable_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `code_i` | `input` | `input logic [DATA_WIDTH+secded_layout_pkg::check_bits_for(DATA_WIDTH):0] code_i` |
| `data_o` | `output` | `output logic [DATA_WIDTH-1:0] data_o` |
| `syndrome_o` | `output` | `output logic [secded_layout_pkg::check_bits_for(DATA_WIDTH)-1:0] syndrome_o` |
| `corrected_o` | `output` | `output logic corrected_o` |
| `overall_parity_error_o` | `output` | `output logic overall_parity_error_o` |
| `uncorrectable_o` | `output` | `output logic uncorrectable_o` |

## Integration and Use

Treat decoded data as invalid when `uncorrectable_o` is high and use exactly the matching encoder geometry.

```systemverilog
secded_decode #(
    .DATA_WIDTH(DATA_WIDTH)
) u_secded_decode (
    .code_i(code_i),
    .data_o(data_o),
    .syndrome_o(syndrome_o),
    .corrected_o(corrected_o),
    .overall_parity_error_o(overall_parity_error_o),
    .uncorrectable_o(uncorrectable_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
