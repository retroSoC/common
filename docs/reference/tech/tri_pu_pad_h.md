# tri_pu_pad_h

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/tech/gpio_pad.sv`](../../../rtl/tech/gpio_pad.sv) |
| Availability | Technology model; replace in an ASIC technology flow |

## Summary

Horizontal pull-up pad abstraction.

## Functional Behavior

Horizontal pull-up pad abstraction. It supplies portable functional behavior or a backend substitution hook, not characterized silicon timing or power behavior.

## Suitable Applications

Use for simulation, generic synthesis, FPGA prototyping, and technology-independent elaboration.

## Parameters

This unit has no configurable parameters.

## Interface Definition

```systemverilog
module tri_pu_pad_h (
    input  logic i_i,
    input  logic oen_i,
    input  logic ren_i,
    output logic c_o,
    inout  wire  pad_io
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `i_i` | `input` | `input  logic i_i` |
| `oen_i` | `input` | `input  logic oen_i` |
| `ren_i` | `input` | `input  logic ren_i` |
| `c_o` | `output` | `output logic c_o` |
| `pad_io` | `inout` | `inout  wire  pad_io` |

## Integration and Use

Replace it through the target technology flow before ASIC tape-out. Treat its active-low controls and backend macros as part of the integration contract.

```systemverilog
tri_pu_pad_h u_tri_pu_pad_h (
    .i_i(i_i),
    .oen_i(oen_i),
    .ren_i(ren_i),
    .c_o(c_o),
    .pad_io(pad_io)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
