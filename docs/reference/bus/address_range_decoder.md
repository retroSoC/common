# address_range_decoder

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/bus/address_advanced.sv`](../../../rtl/bus/address_advanced.sv) |
| Availability | Synthesizable RTL |

## Summary

Inclusive address-range decoder.

## Functional Behavior

Inclusive address-range decoder. It classifies the presented address using the configured decode rule and returns the documented selection/match result combinationally.

## Suitable Applications

Use for memory maps, peripheral selection, firewall regions, and target routing.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `ADDR_WIDTH` | `parameter int ADDR_WIDTH  = 32` |
| `RULES` | `parameter int RULES       = 4` |
| `TARGETS` | `parameter int TARGETS     = 4` |
| `INDEX_WIDTH` | `parameter int INDEX_WIDTH = (TARGETS > 1) ? $clog2(TARGETS) : 1` |

## Interface Definition

```systemverilog
module address_range_decoder #(
    parameter int ADDR_WIDTH  = 32,
    parameter int RULES       = 4,
    parameter int TARGETS     = 4,
    parameter int INDEX_WIDTH = (TARGETS > 1) ? $clog2(TARGETS) : 1
) (
    input  logic [ ADDR_WIDTH-1:0]                  addr_i,
    input  logic [      RULES-1:0][INDEX_WIDTH-1:0] target_i,
    input  logic [      RULES-1:0][ ADDR_WIDTH-1:0] first_i,
    input  logic [      RULES-1:0][ ADDR_WIDTH-1:0] last_i,
    input  logic                                    updating_i,
    input  logic                                    default_enable_i,
    input  logic [INDEX_WIDTH-1:0]                  default_target_i,
    output logic [    TARGETS-1:0]                  select_o,
    output logic [INDEX_WIDTH-1:0]                  target_o,
    output logic                                    valid_o,
    output logic                                    error_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `addr_i` | `input` | `input  logic [ ADDR_WIDTH-1:0]                  addr_i` |
| `target_i` | `input` | `input  logic [      RULES-1:0][INDEX_WIDTH-1:0] target_i` |
| `first_i` | `input` | `input  logic [      RULES-1:0][ ADDR_WIDTH-1:0] first_i` |
| `last_i` | `input` | `input  logic [      RULES-1:0][ ADDR_WIDTH-1:0] last_i` |
| `updating_i` | `input` | `input  logic                                    updating_i` |
| `default_enable_i` | `input` | `input  logic                                    default_enable_i` |
| `default_target_i` | `input` | `input  logic [INDEX_WIDTH-1:0]                  default_target_i` |
| `select_o` | `output` | `output logic [    TARGETS-1:0]                  select_o` |
| `target_o` | `output` | `output logic [INDEX_WIDTH-1:0]                  target_o` |
| `valid_o` | `output` | `output logic                                    valid_o` |
| `error_o` | `output` | `output logic                                    error_o` |

## Integration and Use

Check overlaps and priority deliberately. Decode does not by itself complete or validate a bus transaction.

```systemverilog
address_range_decoder #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .RULES(RULES),
    .TARGETS(TARGETS),
    .INDEX_WIDTH(INDEX_WIDTH)
) u_address_range_decoder (
    .addr_i(addr_i),
    .target_i(target_i),
    .first_i(first_i),
    .last_i(last_i),
    .updating_i(updating_i),
    .default_enable_i(default_enable_i),
    .default_target_i(default_target_i),
    .select_o(select_o),
    .target_o(target_o),
    .valid_o(valid_o),
    .error_o(error_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
