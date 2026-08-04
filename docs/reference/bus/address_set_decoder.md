# address_set_decoder

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/bus/address_advanced.sv`](../../../rtl/bus/address_advanced.sv) |
| Availability | Synthesizable RTL |

## Summary

Decoder for a set of independently configured address regions.

## Functional Behavior

Decoder for a set of independently configured address regions. It classifies the presented address using the configured decode rule and returns the documented selection/match result combinationally.

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
module address_set_decoder #(
    parameter int ADDR_WIDTH  = 32,
    parameter int RULES       = 4,
    parameter int TARGETS     = 4,
    parameter int INDEX_WIDTH = (TARGETS > 1) ? $clog2(TARGETS) : 1
) (
    input  logic [ ADDR_WIDTH-1:0]                  addr_i,
    input  logic [ ADDR_WIDTH-1:0]                  wildcard_i,
    input  logic [      RULES-1:0][INDEX_WIDTH-1:0] target_i,
    input  logic [      RULES-1:0][ ADDR_WIDTH-1:0] rule_addr_i,
    input  logic [      RULES-1:0][ ADDR_WIDTH-1:0] rule_wildcard_i,
    input  logic                                    default_enable_i,
    input  logic [INDEX_WIDTH-1:0]                  default_target_i,
    output logic [    TARGETS-1:0]                  select_o,
    output logic [    TARGETS-1:0][ ADDR_WIDTH-1:0] addr_o,
    output logic [    TARGETS-1:0][ ADDR_WIDTH-1:0] wildcard_o,
    output logic                                    valid_o,
    output logic                                    error_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `addr_i` | `input` | `input  logic [ ADDR_WIDTH-1:0]                  addr_i` |
| `wildcard_i` | `input` | `input  logic [ ADDR_WIDTH-1:0]                  wildcard_i` |
| `target_i` | `input` | `input  logic [      RULES-1:0][INDEX_WIDTH-1:0] target_i` |
| `rule_addr_i` | `input` | `input  logic [      RULES-1:0][ ADDR_WIDTH-1:0] rule_addr_i` |
| `rule_wildcard_i` | `input` | `input  logic [      RULES-1:0][ ADDR_WIDTH-1:0] rule_wildcard_i` |
| `default_enable_i` | `input` | `input  logic                                    default_enable_i` |
| `default_target_i` | `input` | `input  logic [INDEX_WIDTH-1:0]                  default_target_i` |
| `select_o` | `output` | `output logic [    TARGETS-1:0]                  select_o` |
| `addr_o` | `output` | `output logic [    TARGETS-1:0][ ADDR_WIDTH-1:0] addr_o` |
| `wildcard_o` | `output` | `output logic [    TARGETS-1:0][ ADDR_WIDTH-1:0] wildcard_o` |
| `valid_o` | `output` | `output logic                                    valid_o` |
| `error_o` | `output` | `output logic                                    error_o` |

## Integration and Use

Check overlaps and priority deliberately. Decode does not by itself complete or validate a bus transaction.

```systemverilog
address_set_decoder #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .RULES(RULES),
    .TARGETS(TARGETS),
    .INDEX_WIDTH(INDEX_WIDTH)
) u_address_set_decoder (
    .addr_i(addr_i),
    .wildcard_i(wildcard_i),
    .target_i(target_i),
    .rule_addr_i(rule_addr_i),
    .rule_wildcard_i(rule_wildcard_i),
    .default_enable_i(default_enable_i),
    .default_target_i(default_target_i),
    .select_o(select_o),
    .addr_o(addr_o),
    .wildcard_o(wildcard_o),
    .valid_o(valid_o),
    .error_o(error_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
