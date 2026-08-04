# clk_buf

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/tech/stdcell.sv`](../../../rtl/tech/stdcell.sv) |
| Availability | Technology model; replace in an ASIC technology flow |

## Summary

Behavioral clock buffer model.

## Functional Behavior

Behavioral clock buffer model. It supplies portable functional behavior or a backend substitution hook, not characterized silicon timing or power behavior.

## Suitable Applications

Use for simulation, generic synthesis, FPGA prototyping, and technology-independent elaboration.

## Parameters

This unit has no configurable parameters.

## Interface Definition

```systemverilog
module clk_buf (
    input  logic clk_i,
    output logic clk_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic clk_i` |
| `clk_o` | `output` | `output logic clk_o` |

## Integration and Use

Replace it through the target technology flow before ASIC tape-out. Treat its active-low controls and backend macros as part of the integration contract.

```systemverilog
clk_buf u_clk_buf (
    .clk_i(clk_i),
    .clk_o(clk_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
