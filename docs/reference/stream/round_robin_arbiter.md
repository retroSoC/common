# round_robin_arbiter

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/stream/round_robin_arbiter.sv`](../../../rtl/stream/round_robin_arbiter.sv) |
| Availability | Synthesizable RTL |

## Summary

Fair transfer-driven round-robin arbiter.

## Functional Behavior

Fair transfer-driven round-robin arbiter. It follows the repository valid/ready rule: a payload transfers only when both signals are high in the same cycle, and a stalled valid payload remains stable.

## Suitable Applications

Use for elastic pipelines, stream routing, arbitration, backpressure, and response handling.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `CLIENTS` | `parameter int CLIENTS     = 4` |
| `INDEX_WIDTH` | `parameter int INDEX_WIDTH = (CLIENTS > 1) ? $clog2(CLIENTS) : 1` |

## Interface Definition

```systemverilog
module round_robin_arbiter #(
    parameter int CLIENTS     = 4,
    parameter int INDEX_WIDTH = (CLIENTS > 1) ? $clog2(CLIENTS) : 1
) (
    input  logic                   clk_i,
    input  logic                   rst_n_i,
    input  logic                   advance_i,
    input  logic [    CLIENTS-1:0] request_i,
    output logic [    CLIENTS-1:0] grant_o,
    output logic [INDEX_WIDTH-1:0] selected_o,
    output logic                   valid_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                   clk_i` |
| `rst_n_i` | `input` | `input  logic                   rst_n_i` |
| `advance_i` | `input` | `input  logic                   advance_i` |
| `request_i` | `input` | `input  logic [    CLIENTS-1:0] request_i` |
| `grant_o` | `output` | `output logic [    CLIENTS-1:0] grant_o` |
| `selected_o` | `output` | `output logic [INDEX_WIDTH-1:0] selected_o` |
| `valid_o` | `output` | `output logic                   valid_o` |

## Integration and Use

Observe vector sizing, selection encoding, and flush semantics in the declaration. Do not modify a valid payload while its corresponding ready is low.

```systemverilog
round_robin_arbiter #(
    .CLIENTS(CLIENTS),
    .INDEX_WIDTH(INDEX_WIDTH)
) u_round_robin_arbiter (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .advance_i(advance_i),
    .request_i(request_i),
    .grant_o(grant_o),
    .selected_o(selected_o),
    .valid_o(valid_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
