# axi4_regslice

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/bus/axi4_regslice.sv`](../../../rtl/bus/axi4_regslice.sv) |
| Availability | Synthesizable RTL |

## Summary

Elastic register slice for all five AXI4 channels.

## Functional Behavior

Elastic register slice for all five AXI4 channels. It classifies the presented address using the configured decode rule and returns the documented selection/match result combinationally.

## Suitable Applications

Use for memory maps, peripheral selection, firewall regions, and target routing.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `ADDR_WIDTH` | `parameter int ADDR_WIDTH = 32` |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 32` |
| `ID_WIDTH` | `parameter int ID_WIDTH   = 1` |
| `USER_WIDTH` | `parameter int USER_WIDTH = 1` |
| `BYPASS` | `parameter bit BYPASS     = 1'b0` |

## Interface Definition

```systemverilog
module axi4_regslice #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int ID_WIDTH   = 1,
    parameter int USER_WIDTH = 1,
    parameter bit BYPASS     = 1'b0
) (
    input logic   clk_i,
    input logic   rst_n_i,
    input logic   flush_i,
          axi4_if slv,
          axi4_if mst
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input logic   clk_i` |
| `rst_n_i` | `input` | `input logic   rst_n_i` |
| `flush_i` | `input` | `input logic   flush_i` |

## Integration and Use

Check overlaps and priority deliberately. Decode does not by itself complete or validate a bus transaction.

```systemverilog
axi4_regslice #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .ID_WIDTH(ID_WIDTH),
    .USER_WIDTH(USER_WIDTH),
    .BYPASS(BYPASS)
) u_axi4_regslice (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .flush_i(flush_i)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
