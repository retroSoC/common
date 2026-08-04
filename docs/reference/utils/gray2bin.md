# gray2bin

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/utils/gray2bin.sv`](../../../rtl/utils/gray2bin.sv) |
| Availability | Synthesizable RTL |

## Summary

Combinational Gray-to-binary code converter.

## Functional Behavior

Combinational Gray-to-binary code converter. Its exact parameters and ports are reproduced below from the implementation declaration.

## Suitable Applications

Use as a small reusable datapath, state, coding, delay, or verification primitive.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 1` |

## Interface Definition

```systemverilog
module gray2bin #(
    parameter int DATA_WIDTH = 1
) (
    input  logic [DATA_WIDTH-1:0] gray_i,
    output logic [DATA_WIDTH-1:0] bin_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `gray_i` | `input` | `input  logic [DATA_WIDTH-1:0] gray_i` |
| `bin_o` | `output` | `output logic [DATA_WIDTH-1:0] bin_o` |

## Integration and Use

Keep parameter values within RTL assertions and add required clocking, reset, or CDC protection at the caller boundary.

```systemverilog
gray2bin #(
    .DATA_WIDTH(DATA_WIDTH)
) u_gray2bin (
    .gray_i(gray_i),
    .bin_o(bin_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
