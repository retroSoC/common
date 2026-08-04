# clearable_two_phase_link

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/cdc/cdc_advanced.sv`](../../../rtl/cdc/cdc_advanced.sv) |
| Availability | Synthesizable RTL |

## Summary

Two-phase link with coordinated endpoint clear.

## Functional Behavior

Two-phase link with coordinated endpoint clear. It carries the declared control, event, or data contract through the stated synchronizer, handshake, or Gray-pointer mechanism. Endpoint reset discards in-flight data unless the page identifies an acknowledged warm-clear path.

## Suitable Applications

Use for reset release, asynchronous control/data transfer, asynchronous queues, event notification, and CDC recovery.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH  = 32` |
| `SYNC_STAGES` | `parameter int SYNC_STAGES = 3` |

## Interface Definition

```systemverilog
module clearable_two_phase_link #(
    parameter int DATA_WIDTH  = 32,
    parameter int SYNC_STAGES = 3
) (
    input  logic                  src_clk_i,
    input  logic                  src_rst_n_i,
    input  logic                  src_clear_i,
    output logic                  src_clear_busy_o,
    input  logic [DATA_WIDTH-1:0] src_data_i,
    input  logic                  src_valid_i,
    output logic                  src_ready_o,
    input  logic                  dst_clk_i,
    input  logic                  dst_rst_n_i,
    input  logic                  dst_clear_i,
    output logic                  dst_clear_busy_o,
    output logic [DATA_WIDTH-1:0] dst_data_o,
    output logic                  dst_valid_o,
    input  logic                  dst_ready_i
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `src_clk_i` | `input` | `input  logic                  src_clk_i` |
| `src_rst_n_i` | `input` | `input  logic                  src_rst_n_i` |
| `src_clear_i` | `input` | `input  logic                  src_clear_i` |
| `src_clear_busy_o` | `output` | `output logic                  src_clear_busy_o` |
| `src_data_i` | `input` | `input  logic [DATA_WIDTH-1:0] src_data_i` |
| `src_valid_i` | `input` | `input  logic                  src_valid_i` |
| `src_ready_o` | `output` | `output logic                  src_ready_o` |
| `dst_clk_i` | `input` | `input  logic                  dst_clk_i` |
| `dst_rst_n_i` | `input` | `input  logic                  dst_rst_n_i` |
| `dst_clear_i` | `input` | `input  logic                  dst_clear_i` |
| `dst_clear_busy_o` | `output` | `output logic                  dst_clear_busy_o` |
| `dst_data_o` | `output` | `output logic [DATA_WIDTH-1:0] dst_data_o` |
| `dst_valid_o` | `output` | `output logic                  dst_valid_o` |
| `dst_ready_i` | `input` | `input  logic                  dst_ready_i` |

## Integration and Use

Never use a simple synchronizer for arbitrary multi-bit data. Keep both endpoint clocks running after reset release and obey all ready/busy outputs.

```systemverilog
clearable_two_phase_link #(
    .DATA_WIDTH(DATA_WIDTH),
    .SYNC_STAGES(SYNC_STAGES)
) u_clearable_two_phase_link (
    .src_clk_i(src_clk_i),
    .src_rst_n_i(src_rst_n_i),
    .src_clear_i(src_clear_i),
    .src_clear_busy_o(src_clear_busy_o),
    .src_data_i(src_data_i),
    .src_valid_i(src_valid_i),
    .src_ready_o(src_ready_o),
    .dst_clk_i(dst_clk_i),
    .dst_rst_n_i(dst_rst_n_i),
    .dst_clear_i(dst_clear_i),
    .dst_clear_busy_o(dst_clear_busy_o),
    .dst_data_o(dst_data_o),
    .dst_valid_o(dst_valid_o),
    .dst_ready_i(dst_ready_i)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
