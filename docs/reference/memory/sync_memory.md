# sync_memory

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/memory/sync_memory.sv`](../../../rtl/memory/sync_memory.sv) |
| Availability | Synthesizable RTL |

## Summary

Portable synchronous memory model with positive-logic controls.

## Functional Behavior

Portable synchronous memory model with positive-logic controls. It implements the declared storage, ordering, banking, or response contract with explicit bounds rather than silently dropping malformed transactions.

## Suitable Applications

Use for local queues, reorder structures, banked stores, and portable memory-backed blocks.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 32` |
| `DEPTH` | `parameter int DEPTH      = 64` |
| `ADDR_WIDTH` | `parameter int ADDR_WIDTH = (DEPTH > 1) ? $clog2(DEPTH) : 1` |

## Interface Definition

```systemverilog
module sync_memory #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 64,
    parameter int ADDR_WIDTH = (DEPTH > 1) ? $clog2(DEPTH) : 1
) (
    input  logic                  clk_i,
    input  logic                  write_enable_i,
    input  logic                  read_enable_i,
    input  logic [ADDR_WIDTH-1:0] addr_i,
    input  logic [DATA_WIDTH-1:0] write_data_i,
    output logic [DATA_WIDTH-1:0] read_data_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                  clk_i` |
| `write_enable_i` | `input` | `input  logic                  write_enable_i` |
| `read_enable_i` | `input` | `input  logic                  read_enable_i` |
| `addr_i` | `input` | `input  logic [ADDR_WIDTH-1:0] addr_i` |
| `write_data_i` | `input` | `input  logic [DATA_WIDTH-1:0] write_data_i` |
| `read_data_o` | `output` | `output logic [DATA_WIDTH-1:0] read_data_o` |

## Integration and Use

Follow address, depth, outstanding-request, and response-order constraints exactly. Reset state does not imply initialized storage contents unless documented.

```systemverilog
sync_memory #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) u_sync_memory (
    .clk_i(clk_i),
    .write_enable_i(write_enable_i),
    .read_enable_i(read_enable_i),
    .addr_i(addr_i),
    .write_data_i(write_data_i),
    .read_data_o(read_data_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
