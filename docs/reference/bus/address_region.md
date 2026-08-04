# address_region

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/bus/address_decode.sv`](../../../rtl/bus/address_decode.sv) |
| Availability | Synthesizable RTL |

## Summary

Masked address-region matcher.

## Functional Behavior

Masked address-region matcher. It classifies the presented address using the configured decode rule and returns the documented selection/match result combinationally.

## Suitable Applications

Use for memory maps, peripheral selection, firewall regions, and target routing.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `ADDR_WIDTH` | `parameter int                    ADDR_WIDTH = 32` |
| `BASE` | `parameter logic [ADDR_WIDTH-1:0] BASE       = '0` |
| `MASK` | `parameter logic [ADDR_WIDTH-1:0] MASK       = '0` |

## Interface Definition

```systemverilog
module address_region #(
    parameter int                    ADDR_WIDTH = 32,
    parameter logic [ADDR_WIDTH-1:0] BASE       = '0,
    parameter logic [ADDR_WIDTH-1:0] MASK       = '0
) (
    input  logic [ADDR_WIDTH-1:0] addr_i,
    output logic                  match_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `addr_i` | `input` | `input  logic [ADDR_WIDTH-1:0] addr_i` |
| `match_o` | `output` | `output logic                  match_o` |

## Integration and Use

Check overlaps and priority deliberately. Decode does not by itself complete or validate a bus transaction.

```systemverilog
address_region #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .BASE(BASE),
    .MASK(MASK)
) u_address_region (
    .addr_i(addr_i),
    .match_o(match_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
