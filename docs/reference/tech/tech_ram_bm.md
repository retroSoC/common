# tech_ram_bm

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/tech/ram.sv`](../../../rtl/tech/ram.sv) |
| Availability | Technology model; replace in an ASIC technology flow |

## Summary

Behavioral byte-masked technology RAM model.

## Functional Behavior

Behavioral byte-masked technology RAM model. It supplies portable functional behavior or a backend substitution hook, not characterized silicon timing or power behavior.

## Suitable Applications

Use for simulation, generic synthesis, FPGA prototyping, and technology-independent elaboration.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `BIT_WIDTH` | `parameter int BIT_WIDTH  = 128` |
| `WORD_DEPTH` | `parameter int WORD_DEPTH = 64` |
| `ADDR_WIDTH` | `parameter int ADDR_WIDTH = (WORD_DEPTH > 1) ? $clog2(WORD_DEPTH) : 1` |
| `BYTE_COUNT` | `parameter int BYTE_COUNT = BIT_WIDTH / 8` |

## Interface Definition

```systemverilog
module tech_ram_bm #(
    parameter int BIT_WIDTH  = 128,
    parameter int WORD_DEPTH = 64,
    parameter int ADDR_WIDTH = (WORD_DEPTH > 1) ? $clog2(WORD_DEPTH) : 1,
    parameter int BYTE_COUNT = BIT_WIDTH / 8
) (
    input  logic                  clk_i,
    input  logic                  en_i,
    input  logic                  wen_i,
    input  logic [BYTE_COUNT-1:0] bm_i,
    input  logic [ADDR_WIDTH-1:0] addr_i,
    input  logic [ BIT_WIDTH-1:0] dat_i,
    output logic [ BIT_WIDTH-1:0] dat_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                  clk_i` |
| `en_i` | `input` | `input  logic                  en_i` |
| `wen_i` | `input` | `input  logic                  wen_i` |
| `bm_i` | `input` | `input  logic [BYTE_COUNT-1:0] bm_i` |
| `addr_i` | `input` | `input  logic [ADDR_WIDTH-1:0] addr_i` |
| `dat_i` | `input` | `input  logic [ BIT_WIDTH-1:0] dat_i` |
| `dat_o` | `output` | `output logic [ BIT_WIDTH-1:0] dat_o` |

## Integration and Use

Replace it through the target technology flow before ASIC tape-out. Treat its active-low controls and backend macros as part of the integration contract.

```systemverilog
tech_ram_bm #(
    .BIT_WIDTH(BIT_WIDTH),
    .WORD_DEPTH(WORD_DEPTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .BYTE_COUNT(BYTE_COUNT)
) u_tech_ram_bm (
    .clk_i(clk_i),
    .en_i(en_i),
    .wen_i(wen_i),
    .bm_i(bm_i),
    .addr_i(addr_i),
    .dat_i(dat_i),
    .dat_o(dat_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
