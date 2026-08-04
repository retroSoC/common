# cdc_reset_barrier

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/cdc/cdc_rst_ctrlr.sv`](../../../rtl/cdc/cdc_rst_ctrlr.sv) |
| Availability | Synthesizable RTL |

## Summary

Two-domain reset barrier with synchronized release.

## Functional Behavior

Asynchronously asserts local reset and releases it through synchronized reset chains in both supplied clock domains, preventing either side from running before the shared reset epoch is released.

## Suitable Applications

Use when two collaborating domains need a coordinated reset release before starting a CDC protocol.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `STAGES` | `parameter int STAGES = 3` |

## Interface Definition

```systemverilog
module cdc_reset_barrier #(
    parameter int STAGES = 3
) (
    input  logic clk_a_i,
    input  logic clk_b_i,
    input  logic rst_n_i,
    input  logic release_i,
    output logic rst_a_n_o,
    output logic rst_b_n_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_a_i` | `input` | `input  logic clk_a_i` |
| `clk_b_i` | `input` | `input  logic clk_b_i` |
| `rst_n_i` | `input` | `input  logic rst_n_i` |
| `release_i` | `input` | `input  logic release_i` |
| `rst_a_n_o` | `output` | `output logic rst_a_n_o` |
| `rst_b_n_o` | `output` | `output logic rst_b_n_o` |

## Integration and Use

It does not transfer data or replace reset-domain signoff. Both clocks must run for reset release to complete.

```systemverilog
cdc_reset_barrier #(
    .STAGES(STAGES)
) u_cdc_reset_barrier (
    .clk_a_i(clk_a_i),
    .clk_b_i(clk_b_i),
    .rst_n_i(rst_n_i),
    .release_i(release_i),
    .rst_a_n_o(rst_a_n_o),
    .rst_b_n_o(rst_b_n_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
