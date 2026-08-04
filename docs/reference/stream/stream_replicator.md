# stream_replicator

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/stream/stream_cells.sv`](../../../rtl/stream/stream_cells.sv) |
| Availability | Synthesizable RTL |

## Summary

Registered one-item stream distributor with per-target completion.

## Functional Behavior

Captures one input payload and target mask, then presents it to every enabled target exactly once as each target becomes ready. It releases input backpressure only after all selected transfers complete.

## Suitable Applications

Use for multicast command/data distribution with independently stalling consumers.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 32` |
| `PORTS` | `parameter int PORTS      = 4` |

## Interface Definition

```systemverilog
module stream_replicator #(
    parameter int DATA_WIDTH = 32,
    parameter int PORTS      = 4
) (
    input  logic                                  clk_i,
    input  logic                                  rst_n_i,
    input  logic                                  flush_i,
    input  logic                                  in_valid_i,
    output logic                                  in_ready_o,
    input  logic [DATA_WIDTH-1:0]                 in_data_i,
    input  logic [     PORTS-1:0]                 enable_i,
    output logic [     PORTS-1:0]                 out_valid_o,
    input  logic [     PORTS-1:0]                 out_ready_i,
    output logic [     PORTS-1:0][DATA_WIDTH-1:0] out_data_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                                  clk_i` |
| `rst_n_i` | `input` | `input  logic                                  rst_n_i` |
| `flush_i` | `input` | `input  logic                                  flush_i` |
| `in_valid_i` | `input` | `input  logic                                  in_valid_i` |
| `in_ready_o` | `output` | `output logic                                  in_ready_o` |
| `in_data_i` | `input` | `input  logic [DATA_WIDTH-1:0]                 in_data_i` |
| `enable_i` | `input` | `input  logic [     PORTS-1:0]                 enable_i` |
| `out_valid_o` | `output` | `output logic [     PORTS-1:0]                 out_valid_o` |
| `out_ready_i` | `input` | `input  logic [     PORTS-1:0]                 out_ready_i` |
| `out_data_o` | `output` | `output logic [     PORTS-1:0][DATA_WIDTH-1:0] out_data_o` |

## Integration and Use

The mask is sampled only on input acceptance. `flush_i` aborts a retained item; downstream consumers must obey normal valid/ready semantics.

```systemverilog
stream_replicator #(
    .DATA_WIDTH(DATA_WIDTH),
    .PORTS(PORTS)
) u_stream_replicator (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .flush_i(flush_i),
    .in_valid_i(in_valid_i),
    .in_ready_o(in_ready_o),
    .in_data_i(in_data_i),
    .enable_i(enable_i),
    .out_valid_o(out_valid_o),
    .out_ready_i(out_ready_i),
    .out_data_o(out_data_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
