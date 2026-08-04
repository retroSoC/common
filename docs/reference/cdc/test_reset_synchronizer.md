# test_reset_synchronizer

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/cdc/cdc_advanced.sv`](../../../rtl/cdc/cdc_advanced.sv) |
| Availability | Verification-oriented helper |

## Summary

Verification-oriented reset synchronization helper.

## Functional Behavior

Verification-oriented reset synchronization helper. It carries the declared control, event, or data contract through the stated synchronizer, handshake, or Gray-pointer mechanism. Endpoint reset discards in-flight data unless the page identifies an acknowledged warm-clear path.

## Suitable Applications

Use for reset release, asynchronous control/data transfer, asynchronous queues, event notification, and CDC recovery.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `STAGES` | `parameter int STAGES = 3` |

## Interface Definition

```systemverilog
module test_reset_synchronizer #(
    parameter int STAGES = 3
) (
    input  logic clk_i,
    input  logic functional_rst_n_i,
    input  logic test_rst_n_i,
    input  logic test_mode_i,
    output logic rst_n_o,
    output logic init_n_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic clk_i` |
| `functional_rst_n_i` | `input` | `input  logic functional_rst_n_i` |
| `test_rst_n_i` | `input` | `input  logic test_rst_n_i` |
| `test_mode_i` | `input` | `input  logic test_mode_i` |
| `rst_n_o` | `output` | `output logic rst_n_o` |
| `init_n_o` | `output` | `output logic init_n_o` |

## Integration and Use

Never use a simple synchronizer for arbitrary multi-bit data. Keep both endpoint clocks running after reset release and obey all ready/busy outputs.

```systemverilog
test_reset_synchronizer #(
    .STAGES(STAGES)
) u_test_reset_synchronizer (
    .clk_i(clk_i),
    .functional_rst_n_i(functional_rst_n_i),
    .test_rst_n_i(test_rst_n_i),
    .test_mode_i(test_mode_i),
    .rst_n_o(rst_n_o),
    .init_n_o(init_n_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
