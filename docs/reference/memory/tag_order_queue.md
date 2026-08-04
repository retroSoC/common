# tag_order_queue

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/memory/data_structures.sv`](../../../rtl/memory/data_structures.sv) |
| Availability | Synthesizable RTL |

## Summary

Shared-pool queue preserving FIFO order within each tag.

## Functional Behavior

Shared-pool queue preserving FIFO order within each tag. It implements the declared storage, ordering, banking, or response contract with explicit bounds rather than silently dropping malformed transactions.

## Suitable Applications

Use for local queues, reorder structures, banked stores, and portable memory-backed blocks.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH        = 32` |
| `TAG_WIDTH` | `parameter int TAG_WIDTH         = 2` |
| `CAPACITY` | `parameter int CAPACITY          = 8` |
| `COMPARE_PORTS` | `parameter int COMPARE_PORTS     = 1` |
| `REUSE_POPPED_SLOT` | `parameter bit REUSE_POPPED_SLOT = 1'b1` |
| `NODE_WIDTH` | `parameter int NODE_WIDTH        = (CAPACITY > 1) ? $clog2(CAPACITY) : 1` |

## Interface Definition

```systemverilog
module tag_order_queue #(
    parameter int DATA_WIDTH        = 32,
    parameter int TAG_WIDTH         = 2,
    parameter int CAPACITY          = 8,
    parameter int COMPARE_PORTS     = 1,
    parameter bit REUSE_POPPED_SLOT = 1'b1,
    parameter int NODE_WIDTH        = (CAPACITY > 1) ? $clog2(CAPACITY) : 1
) (
    input  logic                                     clk_i,
    input  logic                                     rst_n_i,
    input  logic                                     clear_i,
    input  logic                                     write_valid_i,
    output logic                                     write_ready_o,
    input  logic [    TAG_WIDTH-1:0]                 write_tag_i,
    input  logic [   DATA_WIDTH-1:0]                 write_data_i,
    input  logic                                     read_request_i,
    input  logic [    TAG_WIDTH-1:0]                 read_tag_i,
    input  logic                                     read_take_i,
    output logic                                     read_ready_o,
    output logic                                     read_found_o,
    output logic [   DATA_WIDTH-1:0]                 read_data_o,
    input  logic [COMPARE_PORTS-1:0][DATA_WIDTH-1:0] compare_data_i,
    input  logic [COMPARE_PORTS-1:0][DATA_WIDTH-1:0] compare_mask_i,
    input  logic [COMPARE_PORTS-1:0]                 compare_valid_i,
    output logic [COMPARE_PORTS-1:0]                 compare_found_o,
    output logic                                     full_o,
    output logic                                     empty_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                                     clk_i` |
| `rst_n_i` | `input` | `input  logic                                     rst_n_i` |
| `clear_i` | `input` | `input  logic                                     clear_i` |
| `write_valid_i` | `input` | `input  logic                                     write_valid_i` |
| `write_ready_o` | `output` | `output logic                                     write_ready_o` |
| `write_tag_i` | `input` | `input  logic [    TAG_WIDTH-1:0]                 write_tag_i` |
| `write_data_i` | `input` | `input  logic [   DATA_WIDTH-1:0]                 write_data_i` |
| `read_request_i` | `input` | `input  logic                                     read_request_i` |
| `read_tag_i` | `input` | `input  logic [    TAG_WIDTH-1:0]                 read_tag_i` |
| `read_take_i` | `input` | `input  logic                                     read_take_i` |
| `read_ready_o` | `output` | `output logic                                     read_ready_o` |
| `read_found_o` | `output` | `output logic                                     read_found_o` |
| `read_data_o` | `output` | `output logic [   DATA_WIDTH-1:0]                 read_data_o` |
| `compare_data_i` | `input` | `input  logic [COMPARE_PORTS-1:0][DATA_WIDTH-1:0] compare_data_i` |
| `compare_mask_i` | `input` | `input  logic [COMPARE_PORTS-1:0][DATA_WIDTH-1:0] compare_mask_i` |
| `compare_valid_i` | `input` | `input  logic [COMPARE_PORTS-1:0]                 compare_valid_i` |
| `compare_found_o` | `output` | `output logic [COMPARE_PORTS-1:0]                 compare_found_o` |
| `full_o` | `output` | `output logic                                     full_o` |
| `empty_o` | `output` | `output logic                                     empty_o` |

## Integration and Use

Follow address, depth, outstanding-request, and response-order constraints exactly. Reset state does not imply initialized storage contents unless documented.

```systemverilog
tag_order_queue #(
    .DATA_WIDTH(DATA_WIDTH),
    .TAG_WIDTH(TAG_WIDTH),
    .CAPACITY(CAPACITY),
    .COMPARE_PORTS(COMPARE_PORTS),
    .REUSE_POPPED_SLOT(REUSE_POPPED_SLOT),
    .NODE_WIDTH(NODE_WIDTH)
) u_tag_order_queue (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .clear_i(clear_i),
    .write_valid_i(write_valid_i),
    .write_ready_o(write_ready_o),
    .write_tag_i(write_tag_i),
    .write_data_i(write_data_i),
    .read_request_i(read_request_i),
    .read_tag_i(read_tag_i),
    .read_take_i(read_take_i),
    .read_ready_o(read_ready_o),
    .read_found_o(read_found_o),
    .read_data_o(read_data_o),
    .compare_data_i(compare_data_i),
    .compare_mask_i(compare_mask_i),
    .compare_valid_i(compare_valid_i),
    .compare_found_o(compare_found_o),
    .full_o(full_o),
    .empty_o(empty_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
