# async_reqack

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/cdc/async_reqack.sv`](../../../rtl/cdc/async_reqack.sv) |
| Availability | Synthesizable RTL |

## Summary

One-entry four-phase asynchronous data mailbox.

## Functional Behavior

Captures one source payload, transfers it through a four-phase request/acknowledge protocol, and suppresses destination valid after acceptance so return-to-zero cannot create a duplicate delivery.

## Suitable Applications

Use for low-throughput asynchronous control or data mailboxes.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH  = 32` |
| `SYNC_STAGES` | `parameter int SYNC_STAGES = 2` |

## Interface Definition

```systemverilog
module async_reqack #(
    parameter int DATA_WIDTH  = 32,
    parameter int SYNC_STAGES = 2
) (
    input  logic                  src_clk_i,
    input  logic                  src_rst_n_i,
    input  logic                  src_valid_i,
    output logic                  src_ready_o,
    input  logic [DATA_WIDTH-1:0] src_data_i,
    input  logic                  dst_clk_i,
    input  logic                  dst_rst_n_i,
    output logic                  dst_valid_o,
    input  logic                  dst_ready_i,
    output logic [DATA_WIDTH-1:0] dst_data_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `src_clk_i` | `input` | `input  logic                  src_clk_i` |
| `src_rst_n_i` | `input` | `input  logic                  src_rst_n_i` |
| `src_valid_i` | `input` | `input  logic                  src_valid_i` |
| `src_ready_o` | `output` | `output logic                  src_ready_o` |
| `src_data_i` | `input` | `input  logic [DATA_WIDTH-1:0] src_data_i` |
| `dst_clk_i` | `input` | `input  logic                  dst_clk_i` |
| `dst_rst_n_i` | `input` | `input  logic                  dst_rst_n_i` |
| `dst_valid_o` | `output` | `output logic                  dst_valid_o` |
| `dst_ready_i` | `input` | `input  logic                  dst_ready_i` |
| `dst_data_o` | `output` | `output logic [DATA_WIDTH-1:0] dst_data_o` |

## Integration and Use

Hold source payload only through the source valid/ready handshake. Reset at either endpoint aborts an in-flight item; this is a one-entry link.

```systemverilog
async_reqack #(
    .DATA_WIDTH(DATA_WIDTH),
    .SYNC_STAGES(SYNC_STAGES)
) u_async_reqack (
    .src_clk_i(src_clk_i),
    .src_rst_n_i(src_rst_n_i),
    .src_valid_i(src_valid_i),
    .src_ready_o(src_ready_o),
    .src_data_i(src_data_i),
    .dst_clk_i(dst_clk_i),
    .dst_rst_n_i(dst_rst_n_i),
    .dst_valid_o(dst_valid_o),
    .dst_ready_i(dst_ready_i),
    .dst_data_o(dst_data_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
