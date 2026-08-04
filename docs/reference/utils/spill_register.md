# spill_register

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/utils/spill_register.sv`](../../../rtl/utils/spill_register.sv) |
| Availability | Synthesizable RTL |

## Summary

Two-register spill stage for breaking ready timing paths.

## Functional Behavior

Uses a primary register plus spill storage to retain input data during downstream stalls while decoupling the ready path. Optional bypass changes empty-state latency only.

## Suitable Applications

Use at stream timing boundaries where combinational ready propagation is too long.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 32` |
| `BYPASS` | `parameter bit BYPASS     = 1'b0  // transparent` |

## Interface Definition

```systemverilog
module spill_register #(
    parameter int DATA_WIDTH = 32,
    parameter bit BYPASS     = 1'b0  // transparent
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  flush_i,
    input  logic                  valid_i,
    output logic                  ready_o,
    input  logic [DATA_WIDTH-1:0] data_i,
    output logic                  valid_o,
    input  logic                  ready_i,
    output logic [DATA_WIDTH-1:0] data_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                  clk_i` |
| `rst_n_i` | `input` | `input  logic                  rst_n_i` |
| `flush_i` | `input` | `input  logic                  flush_i` |
| `valid_i` | `input` | `input  logic                  valid_i` |
| `ready_o` | `output` | `output logic                  ready_o` |
| `data_i` | `input` | `input  logic [DATA_WIDTH-1:0] data_i` |
| `valid_o` | `output` | `output logic                  valid_o` |
| `ready_i` | `input` | `input  logic                  ready_i` |
| `data_o` | `output` | `output logic [DATA_WIDTH-1:0] data_o` |

## Integration and Use

Follow valid/ready stability rules and treat `flush_i` as an abort of retained data. Check bypass timing before using it across a long path.

```systemverilog
spill_register #(
    .DATA_WIDTH(DATA_WIDTH),
    .BYPASS(BYPASS)
) u_spill_register (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .flush_i(flush_i),
    .valid_i(valid_i),
    .ready_o(ready_o),
    .data_i(data_i),
    .valid_o(valid_o),
    .ready_i(ready_i),
    .data_o(data_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
