# apb4_master_model

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/model/apb4_master_model.sv`](../../../rtl/model/apb4_master_model.sv) |
| Availability | Simulation/verification model |

## Summary

Simulation APB4 master model.

## Functional Behavior

Simulation APB4 master model. It models the protocol action for simulation and is not a synthesizable protocol endpoint.

## Suitable Applications

Use in a SystemVerilog testbench or directed protocol smoke test.

## Parameters

This unit has no configurable parameters.

## Interface Definition

```systemverilog
module apb4_master_model (
    apb4_if.master apb4
);
```


## Integration and Use

Include the required interface/configuration definitions and do not include this model in a silicon file list.

```systemverilog
apb4_master_model u_apb4_master_model (

);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
