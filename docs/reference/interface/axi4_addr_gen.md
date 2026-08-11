# axi4_addr_gen

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/interface/axi4_addr_gen.sv`](../../../rtl/interface/axi4_addr_gen.sv) |
| Availability | Synthesizable RTL |

## Summary

AXI4 next-address generator for FIXED, INCR, and legal WRAP bursts.

## Functional Behavior

AXI4 next-address generator for FIXED, INCR, and legal WRAP bursts. It groups protocol signals and constrains endpoint direction with the declared modports; it does not implement protocol state or drive behavior itself.

## Suitable Applications

Use to connect compatible SystemVerilog RTL or class-based verification components without duplicating a port bundle.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `ADDR_WIDTH` | `parameter int ADDR_WIDTH = `AXI4_ADDR_OFT_WIDTH` |

## Interface Definition

```systemverilog
module axi4_addr_gen #(
    parameter int ADDR_WIDTH = `AXI4_ADDR_OFT_WIDTH
) (
    input  logic [           7:0] alen_i,
    input  logic [           2:0] asize_i,
    input  logic [           1:0] aburst_i,
    input  logic [ADDR_WIDTH-1:0] addr_i,
    output logic [ADDR_WIDTH-1:0] addr_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `alen_i` | `input` | `input  logic [           7:0] alen_i` |
| `asize_i` | `input` | `input  logic [           2:0] asize_i` |
| `aburst_i` | `input` | `input  logic [           1:0] aburst_i` |
| `addr_i` | `input` | `input  logic [ADDR_WIDTH-1:0] addr_i` |
| `addr_o` | `output` | `output logic [ADDR_WIDTH-1:0] addr_o` |

## Integration and Use

Connect the correct modport for each role. The connected logic remains responsible for all protocol timing and reset behavior.

```systemverilog
axi4_addr_gen #(
    .ADDR_WIDTH(ADDR_WIDTH)
) u_axi4_addr_gen (
    .alen_i(alen_i),
    .asize_i(asize_i),
    .aburst_i(aburst_i),
    .addr_i(addr_i),
    .addr_o(addr_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
