# credit_pool

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/base/control_cells.sv`](../../../rtl/base/control_cells.sv) |
| Availability | Synthesizable RTL |

## Summary

Saturating available-credit tracker for resource flow control.

## Functional Behavior

Tracks returned (`give_i`) and consumed (`take_i`) credits. Simultaneous give/take has zero net change; full, empty, and one-from-full outputs observe the current state.

## Suitable Applications

Use for bounded request windows, queue slots, buffer credits, and response throttling.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `MAX_CREDITS` | `parameter int MAX_CREDITS    = 4` |
| `EMPTY_ON_RESET` | `parameter bit EMPTY_ON_RESET = 1'b0` |
| `COUNT_WIDTH` | `parameter int COUNT_WIDTH    = $clog2(MAX_CREDITS + 1)` |

## Interface Definition

```systemverilog
module credit_pool #(
    parameter int MAX_CREDITS    = 4,
    parameter bit EMPTY_ON_RESET = 1'b0,
    parameter int COUNT_WIDTH    = $clog2(MAX_CREDITS + 1)
) (
    input  logic                   clk_i,
    input  logic                   rst_n_i,
    input  logic                   clear_i,
    input  logic                   give_i,
    input  logic                   take_i,
    output logic [COUNT_WIDTH-1:0] available_o,
    output logic                   has_credit_o,
    output logic                   one_from_full_o,
    output logic                   full_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                   clk_i` |
| `rst_n_i` | `input` | `input  logic                   rst_n_i` |
| `clear_i` | `input` | `input  logic                   clear_i` |
| `give_i` | `input` | `input  logic                   give_i` |
| `take_i` | `input` | `input  logic                   take_i` |
| `available_o` | `output` | `output logic [COUNT_WIDTH-1:0] available_o` |
| `has_credit_o` | `output` | `output logic                   has_credit_o` |
| `one_from_full_o` | `output` | `output logic                   one_from_full_o` |
| `full_o` | `output` | `output logic                   full_o` |

## Integration and Use

Do not issue unpaired gives or takes. `clear_i` is synchronous; choose `EMPTY_ON_RESET` to match resource ownership after reset.

```systemverilog
credit_pool #(
    .MAX_CREDITS(MAX_CREDITS),
    .EMPTY_ON_RESET(EMPTY_ON_RESET),
    .COUNT_WIDTH(COUNT_WIDTH)
) u_credit_pool (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .clear_i(clear_i),
    .give_i(give_i),
    .take_i(take_i),
    .available_o(available_o),
    .has_credit_o(has_credit_o),
    .one_from_full_o(one_from_full_o),
    .full_o(full_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
