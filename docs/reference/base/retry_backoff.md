# retry_backoff

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/base/control_cells.sv`](../../../rtl/base/control_cells.sv) |
| Availability | Synthesizable RTL |

## Summary

Pseudo-random exponential retry-delay controller.

## Functional Behavior

Samples a local Galois-LFSR through an expanding low-bit mask after failure. A nonzero sampled delay deasserts `ready_o` until its wait counter reaches zero; success clears the retry window.

## Suitable Applications

Use for contention retries, shared-resource collision recovery, and congestion backoff.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int                    DATA_WIDTH   = 16` |
| `MAX_EXPONENT` | `parameter int                    MAX_EXPONENT = DATA_WIDTH` |
| `POLYNOMIAL` | `parameter logic [DATA_WIDTH-1:0] POLYNOMIAL   = 16'hB400` |
| `SEED` | `parameter logic [DATA_WIDTH-1:0] SEED         = {{(DATA_WIDTH - 1) {1'b0}}, 1'b1}` |

## Interface Definition

```systemverilog
module retry_backoff #(
    parameter int                    DATA_WIDTH   = 16,
    parameter int                    MAX_EXPONENT = DATA_WIDTH,
    parameter logic [DATA_WIDTH-1:0] POLYNOMIAL   = 16'hB400,
    parameter logic [DATA_WIDTH-1:0] SEED         = {{(DATA_WIDTH - 1) {1'b0}}, 1'b1}
) (
    input  logic clk_i,
    input  logic rst_n_i,
    input  logic clear_i,
    input  logic failure_i,
    input  logic success_i,
    output logic ready_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic clk_i` |
| `rst_n_i` | `input` | `input  logic rst_n_i` |
| `clear_i` | `input` | `input  logic clear_i` |
| `failure_i` | `input` | `input  logic failure_i` |
| `success_i` | `input` | `input  logic success_i` |
| `ready_o` | `output` | `output logic ready_o` |

## Integration and Use

Gate attempts with `ready_o`. A failure during an active wait replaces the delay, while success cancels it.

```systemverilog
retry_backoff #(
    .DATA_WIDTH(DATA_WIDTH),
    .MAX_EXPONENT(MAX_EXPONENT),
    .POLYNOMIAL(POLYNOMIAL),
    .SEED(SEED)
) u_retry_backoff (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .clear_i(clear_i),
    .failure_i(failure_i),
    .success_i(success_i),
    .ready_o(ready_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
