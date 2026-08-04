# sample_majority_filter

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/base/control_cells.sv`](../../../rtl/base/control_cells.sv) |
| Availability | Synthesizable RTL |

## Summary

Sliding-window N-of-M single-bit sample filter.

## Functional Behavior

Retains the most recent enabled samples and asserts when their population count reaches `ASSERT_THRESHOLD`; the default is strict majority.

## Suitable Applications

Use for noisy status pins, repeated sensor samples, redundant indications, and temporal voting.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `WINDOW_LENGTH` | `parameter int WINDOW_LENGTH    = 4` |
| `ASSERT_THRESHOLD` | `parameter int ASSERT_THRESHOLD = (WINDOW_LENGTH / 2) + 1` |
| `COUNT_WIDTH` | `parameter int COUNT_WIDTH      = $clog2(WINDOW_LENGTH + 1)` |

## Interface Definition

```systemverilog
module sample_majority_filter #(
    parameter int WINDOW_LENGTH    = 4,
    parameter int ASSERT_THRESHOLD = (WINDOW_LENGTH / 2) + 1,
    parameter int COUNT_WIDTH      = $clog2(WINDOW_LENGTH + 1)
) (
    input  logic clk_i,
    input  logic rst_n_i,
    input  logic clear_i,
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
| `enable_i` | `input` | `input  logic enable_i` |
| `sample_i` | `input` | `input  logic sample_i` |
| `level_o` | `output` | `output logic level_o` |

## Integration and Use

This is a population filter, not a synchronizer or consecutive-stability filter. Choose the threshold deliberately.

```systemverilog
sample_majority_filter #(
    .WINDOW_LENGTH(WINDOW_LENGTH),
    .ASSERT_THRESHOLD(ASSERT_THRESHOLD),
    .COUNT_WIDTH(COUNT_WIDTH)
) u_sample_majority_filter (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .clear_i(clear_i),
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
