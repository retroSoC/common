# osc_pad_v

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/tech/gpio_pad.sv`](../../../rtl/tech/gpio_pad.sv) |
| Availability | Technology model; replace in an ASIC technology flow |

## Summary

Vertical oscillator pad abstraction.

## Functional Behavior

Vertical oscillator pad abstraction. It supplies portable functional behavior or a backend substitution hook, not characterized silicon timing or power behavior.

## Suitable Applications

Use for simulation, generic synthesis, FPGA prototyping, and technology-independent elaboration.

## Parameters

This unit has no configurable parameters.

## Interface Definition

```systemverilog
module osc_pad_v (
    input  logic ds0_i,   // driver strength
    input  logic ds1_i,   // driver strength
    input  logic en_i,
    input  logic xin_i,
    output logic xout_o,
    output logic xc_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `en_i` | `input` | `input  logic en_i` |
| `xin_i` | `input` | `input  logic xin_i` |
| `xout_o` | `output` | `output logic xout_o` |
| `xc_o` | `output` | `output logic xc_o` |

## Integration and Use

Replace it through the target technology flow before ASIC tape-out. Treat its active-low controls and backend macros as part of the integration contract.

```systemverilog
osc_pad_v u_osc_pad_v (
    .en_i(en_i),
    .xin_i(xin_i),
    .xout_o(xout_o),
    .xc_o(xc_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
