# plru_victim_selector

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/base/replacement.sv`](../../../rtl/base/replacement.sv) |
| Availability | Synthesizable RTL |

## Summary

Power-of-two pseudo-LRU cache-way victim selector.

## Functional Behavior

Power-of-two pseudo-LRU cache-way victim selector. It is a self-contained base primitive with the behavior and parameter checks implemented in the linked RTL source.

## Suitable Applications

Use as a structured building block for control, encoding, ECC, hashing, masking, replacement, or observability logic.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `WAYS` | `parameter int WAYS = 4` |

## Interface Definition

```systemverilog
module plru_victim_selector #(
    parameter int WAYS = 4
) (
    input  logic            clk_i,
    input  logic            rst_n_i,
    input  logic            flush_i,
    input  logic [WAYS-1:0] touch_i,
    output logic [WAYS-1:0] victim_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic            clk_i` |
| `rst_n_i` | `input` | `input  logic            rst_n_i` |
| `flush_i` | `input` | `input  logic            flush_i` |
| `touch_i` | `input` | `input  logic [WAYS-1:0] touch_i` |
| `victim_o` | `output` | `output logic [WAYS-1:0] victim_o` |

## Integration and Use

Honor validity/error outputs and parameter constraints. Combinational cells do not provide timing isolation or CDC protection.

```systemverilog
plru_victim_selector #(
    .WAYS(WAYS)
) u_plru_victim_selector (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .flush_i(flush_i),
    .touch_i(touch_i),
    .victim_o(victim_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
