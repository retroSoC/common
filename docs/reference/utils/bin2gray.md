# bin2gray

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/utils/bin2gray.sv`](../../../rtl/utils/bin2gray.sv) |
| Availability | Synthesizable RTL |

## Summary

Combinational binary-to-Gray code converter.

## Functional Behavior

Combinational binary-to-Gray code converter. Its exact parameters and ports are reproduced below from the implementation declaration.

## Suitable Applications

Use as a small reusable datapath, state, coding, delay, or verification primitive.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 1` |

## Interface Definition

```systemverilog
module bin2gray #(
    parameter int DATA_WIDTH = 1
) (
    input  logic [DATA_WIDTH-1:0] bin_i,
    output logic [DATA_WIDTH-1:0] gray_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `bin_i` | `input` | `input  logic [DATA_WIDTH-1:0] bin_i` |
| `gray_o` | `output` | `output logic [DATA_WIDTH-1:0] gray_o` |

## Integration and Use

Keep parameter values within RTL assertions and add required clocking, reset, or CDC protection at the caller boundary.

```systemverilog
bin2gray #(
    .DATA_WIDTH(DATA_WIDTH)
) u_bin2gray (
    .bin_i(bin_i),
    .gray_o(gray_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
