# tech_pll

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/tech/pll.sv`](../../../rtl/tech/pll.sv) |
| Availability | Technology model; replace in an ASIC technology flow |

## Summary

Technology PLL abstraction.

## Functional Behavior

Technology PLL abstraction. It supplies portable functional behavior or a backend substitution hook, not characterized silicon timing or power behavior.

## Suitable Applications

Use for simulation, generic synthesis, FPGA prototyping, and technology-independent elaboration.

## Parameters

This unit has no configurable parameters.

## Interface Definition

```systemverilog
module tech_pll #(
) (
    input  logic        fref_i,
    input  logic [ 5:0] refdiv_i,
    input        [11:0] fbdiv_i,
    input  logic [ 2:0] postdiv1_i,
    input  logic [ 2:0] postdiv2_i,
    output logic        pll_lock_o,
    output logic        pll_clk_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `fref_i` | `input` | `input  logic        fref_i` |
| `refdiv_i` | `input` | `input  logic [ 5:0] refdiv_i` |
| `fbdiv_i` | `input` | `input        [11:0] fbdiv_i` |
| `postdiv1_i` | `input` | `input  logic [ 2:0] postdiv1_i` |
| `postdiv2_i` | `input` | `input  logic [ 2:0] postdiv2_i` |
| `pll_lock_o` | `output` | `output logic        pll_lock_o` |
| `pll_clk_o` | `output` | `output logic        pll_clk_o` |

## Integration and Use

Replace it through the target technology flow before ASIC tape-out. Treat its active-low controls and backend macros as part of the integration contract.

```systemverilog
tech_pll u_tech_pll (
    .fref_i(fref_i),
    .refdiv_i(refdiv_i),
    .fbdiv_i(fbdiv_i),
    .postdiv1_i(postdiv1_i),
    .postdiv2_i(postdiv2_i),
    .pll_lock_o(pll_lock_o),
    .pll_clk_o(pll_clk_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
