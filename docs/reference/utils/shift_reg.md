# shift_reg

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/utils/shift_reg.sv`](../../../rtl/utils/shift_reg.sv) |
| Availability | Synthesizable RTL |

## Summary

Parameterized sequential shift register.

## Functional Behavior

Parameterized sequential shift register. Its exact parameters and ports are reproduced below from the implementation declaration.

## Suitable Applications

Use as a small reusable datapath, state, coding, delay, or verification primitive.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 8` |
| `SHIFT_NUM` | `parameter int SHIFT_NUM  = 1` |

## Interface Definition

```systemverilog
module shift_reg #(
    parameter int DATA_WIDTH = 8,
    parameter int SHIFT_NUM  = 1
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic [           1:0] type_i,
    input  logic [           1:0] dir_i,
    input  logic                  ld_en_i,
    input  logic                  sft_en_i,
    input  logic [ SHIFT_NUM-1:0] ser_dat_i,
    input  logic [DATA_WIDTH-1:0] par_data_i,
    output logic [ SHIFT_NUM-1:0] ser_dat_o,
    output logic [DATA_WIDTH-1:0] par_data_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                  clk_i` |
| `rst_n_i` | `input` | `input  logic                  rst_n_i` |
| `type_i` | `input` | `input  logic [           1:0] type_i` |
| `dir_i` | `input` | `input  logic [           1:0] dir_i` |
| `ld_en_i` | `input` | `input  logic                  ld_en_i` |
| `sft_en_i` | `input` | `input  logic                  sft_en_i` |
| `ser_dat_i` | `input` | `input  logic [ SHIFT_NUM-1:0] ser_dat_i` |
| `par_data_i` | `input` | `input  logic [DATA_WIDTH-1:0] par_data_i` |
| `ser_dat_o` | `output` | `output logic [ SHIFT_NUM-1:0] ser_dat_o` |
| `par_data_o` | `output` | `output logic [DATA_WIDTH-1:0] par_data_o` |

## Integration and Use

Keep parameter values within RTL assertions and add required clocking, reset, or CDC protection at the caller boundary.

```systemverilog
shift_reg #(
    .DATA_WIDTH(DATA_WIDTH),
    .SHIFT_NUM(SHIFT_NUM)
) u_shift_reg (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .type_i(type_i),
    .dir_i(dir_i),
    .ld_en_i(ld_en_i),
    .sft_en_i(sft_en_i),
    .ser_dat_i(ser_dat_i),
    .par_data_i(par_data_i),
    .ser_dat_o(ser_dat_o),
    .par_data_o(par_data_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
