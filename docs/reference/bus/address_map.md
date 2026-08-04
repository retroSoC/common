# address_map

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/bus/address_decode.sv`](../../../rtl/bus/address_decode.sv) |
| Availability | Synthesizable RTL |

## Summary

Masked address-map decoder with deterministic lowest-index priority.

## Functional Behavior

Masked address-map decoder with deterministic lowest-index priority. It classifies the presented address using the configured decode rule and returns the documented selection/match result combinationally.

## Suitable Applications

Use for memory maps, peripheral selection, firewall regions, and target routing.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `ADDR_WIDTH` | `parameter int ADDR_WIDTH  = 32` |
| `REGIONS` | `parameter int REGIONS     = 4` |
| `INDEX_WIDTH` | `parameter int INDEX_WIDTH = (REGIONS > 1) ? $clog2(REGIONS) : 1` |

## Interface Definition

```systemverilog
module address_map #(
    parameter int ADDR_WIDTH  = 32,
    parameter int REGIONS     = 4,
    parameter int INDEX_WIDTH = (REGIONS > 1) ? $clog2(REGIONS) : 1
) (
    input  logic [ ADDR_WIDTH-1:0]                 addr_i,
    input  logic [    REGIONS-1:0][ADDR_WIDTH-1:0] base_i,
    input  logic [    REGIONS-1:0][ADDR_WIDTH-1:0] mask_i,
    output logic [    REGIONS-1:0]                 hit_o,
    output logic [INDEX_WIDTH-1:0]                 selected_o,
    output logic                                   valid_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `addr_i` | `input` | `input  logic [ ADDR_WIDTH-1:0]                 addr_i` |
| `base_i` | `input` | `input  logic [    REGIONS-1:0][ADDR_WIDTH-1:0] base_i` |
| `mask_i` | `input` | `input  logic [    REGIONS-1:0][ADDR_WIDTH-1:0] mask_i` |
| `hit_o` | `output` | `output logic [    REGIONS-1:0]                 hit_o` |
| `selected_o` | `output` | `output logic [INDEX_WIDTH-1:0]                 selected_o` |
| `valid_o` | `output` | `output logic                                   valid_o` |

## Integration and Use

Check overlaps and priority deliberately. Decode does not by itself complete or validate a bus transaction.

```systemverilog
address_map #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .REGIONS(REGIONS),
    .INDEX_WIDTH(INDEX_WIDTH)
) u_address_map (
    .addr_i(addr_i),
    .base_i(base_i),
    .mask_i(mask_i),
    .hit_o(hit_o),
    .selected_o(selected_o),
    .valid_o(valid_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
