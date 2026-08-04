# regfield

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/utils/regfield.sv`](../../../rtl/utils/regfield.sv) |
| Availability | Synthesizable RTL |

## Summary

Masked register-field update primitive.

## Functional Behavior

Masked register-field update primitive. Its exact parameters and ports are reproduced below from the implementation declaration.

## Suitable Applications

Use as a small reusable datapath, state, coding, delay, or verification primitive.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter                        DATA_WIDTH = 32` |
| `SW_ACS` | `parameter                        SW_ACS     = "rw",  // rw, ro, wo, w1c, w1s, w0c, rc` |
| `RST_VAL` | `parameter logic [DATA_WIDTH-1:0] RST_VAL    = '0     // Reset value` |

## Interface Definition

```systemverilog
module regfield #(
    parameter                        DATA_WIDTH = 32,
    parameter                        SW_ACS     = "rw",  // rw, ro, wo, w1c, w1s, w0c, rc
    parameter logic [DATA_WIDTH-1:0] RST_VAL    = '0     // Reset value
) (
    input                         clk_i,
    input                         rst_n_i,
    // from sw, in case of rc, top connects rd pulse to sw_wen_i
    input                         sw_wen_i,
    input        [DATA_WIDTH-1:0] sw_wdata_i,
    // from hw: valid for hrw, hwo
    input                         hw_wen_i,
    input        [DATA_WIDTH-1:0] hw_wdata_i,
    // output to hw and reg rd
    output logic                  data_en_o,
    output logic [DATA_WIDTH-1:0] data_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input                         clk_i` |
| `rst_n_i` | `input` | `input                         rst_n_i` |
| `sw_wen_i` | `input` | `input                         sw_wen_i` |
| `sw_wdata_i` | `input` | `input        [DATA_WIDTH-1:0] sw_wdata_i` |
| `hw_wen_i` | `input` | `input                         hw_wen_i` |
| `hw_wdata_i` | `input` | `input        [DATA_WIDTH-1:0] hw_wdata_i` |
| `data_en_o` | `output` | `output logic                  data_en_o` |
| `data_o` | `output` | `output logic [DATA_WIDTH-1:0] data_o` |

## Integration and Use

Keep parameter values within RTL assertions and add required clocking, reset, or CDC protection at the caller boundary.

```systemverilog
regfield #(
    .DATA_WIDTH(DATA_WIDTH),
    .SW_ACS(SW_ACS),
    .RST_VAL(RST_VAL)
) u_regfield (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .sw_wen_i(sw_wen_i),
    .sw_wdata_i(sw_wdata_i),
    .hw_wen_i(hw_wen_i),
    .hw_wdata_i(hw_wdata_i),
    .data_en_o(data_en_o),
    .data_o(data_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
