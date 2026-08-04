# stable_level_filter

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/base/control_cells.sv`](../../../rtl/base/control_cells.sv) |
| Availability | Synthesizable RTL |

## Summary

Consecutive-sample debounce and stability filter.

## Functional Behavior

Changes the output only after the sampled level differs from the current output for `STABLE_CYCLES` enabled consecutive clocks. `restart_i` accepts the current sample immediately.

## Suitable Applications

Use for debounced controls, lock indications, slow GPIO state, and reset-status qualification.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `STABLE_CYCLES` | `parameter int STABLE_CYCLES = 4` |
| `COUNT_WIDTH` | `parameter int COUNT_WIDTH   = (STABLE_CYCLES > 1) ? $clog2(STABLE_CYCLES) : 1` |

## Interface Definition

```systemverilog
module stable_level_filter #(
    parameter int STABLE_CYCLES = 4,
    parameter int COUNT_WIDTH   = (STABLE_CYCLES > 1) ? $clog2(STABLE_CYCLES) : 1
) (
    input  logic clk_i,
    input  logic rst_n_i,
    input  logic clear_i,
    input  logic restart_i,
    input  logic enable_i,
    input  logic sample_i,
    output logic level_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic clk_i` |
| `rst_n_i` | `input` | `input  logic rst_n_i` |
| `clear_i` | `input` | `input  logic clear_i` |
| `restart_i` | `input` | `input  logic restart_i` |
| `enable_i` | `input` | `input  logic enable_i` |
| `sample_i` | `input` | `input  logic sample_i` |
| `level_o` | `output` | `output logic level_o` |

## Integration and Use

Synchronize an asynchronous source first. Disabling the filter clears accumulated evidence; `STABLE_CYCLES=1` accepts every enabled sample.

```systemverilog
stable_level_filter #(
    .STABLE_CYCLES(STABLE_CYCLES),
    .COUNT_WIDTH(COUNT_WIDTH)
) u_stable_level_filter (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .clear_i(clear_i),
    .restart_i(restart_i),
    .enable_i(enable_i),
    .sample_i(sample_i),
    .level_o(level_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
