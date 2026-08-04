# circular_store

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/memory/data_structures.sv`](../../../rtl/memory/data_structures.sv) |
| Availability | Synthesizable RTL |

## Summary

Sequential circular store with bounded random reads.

## Functional Behavior

Sequential circular store with bounded random reads. It implements the declared storage, ordering, banking, or response contract with explicit bounds rather than silently dropping malformed transactions.

## Suitable Applications

Use for local queues, reorder structures, banked stores, and portable memory-backed blocks.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 32` |
| `DEPTH` | `parameter int DEPTH      = 8` |
| `ADDR_WIDTH` | `parameter int ADDR_WIDTH = (DEPTH > 1) ? $clog2(DEPTH) : 1` |
| `STEP_WIDTH` | `parameter int STEP_WIDTH = $clog2(DEPTH + 1)` |

## Interface Definition

```systemverilog
module circular_store #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 8,
    parameter int ADDR_WIDTH = (DEPTH > 1) ? $clog2(DEPTH) : 1,
    parameter int STEP_WIDTH = $clog2(DEPTH + 1)
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  clear_i,
    input  logic                  write_valid_i,
    output logic                  write_ready_o,
    input  logic [DATA_WIDTH-1:0] write_data_i,
    input  logic                  read_valid_i,
    output logic                  read_ready_o,
    input  logic [ADDR_WIDTH-1:0] read_addr_i,
    output logic [DATA_WIDTH-1:0] read_data_o,
    input  logic                  retire_i,
    input  logic [STEP_WIDTH-1:0] retire_count_i,
    output logic [ADDR_WIDTH-1:0] write_ptr_o,
    output logic [ADDR_WIDTH-1:0] read_ptr_o,
    output logic                  full_o,
    output logic                  empty_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                  clk_i` |
| `rst_n_i` | `input` | `input  logic                  rst_n_i` |
| `clear_i` | `input` | `input  logic                  clear_i` |
| `write_valid_i` | `input` | `input  logic                  write_valid_i` |
| `write_ready_o` | `output` | `output logic                  write_ready_o` |
| `write_data_i` | `input` | `input  logic [DATA_WIDTH-1:0] write_data_i` |
| `read_valid_i` | `input` | `input  logic                  read_valid_i` |
| `read_ready_o` | `output` | `output logic                  read_ready_o` |
| `read_addr_i` | `input` | `input  logic [ADDR_WIDTH-1:0] read_addr_i` |
| `read_data_o` | `output` | `output logic [DATA_WIDTH-1:0] read_data_o` |
| `retire_i` | `input` | `input  logic                  retire_i` |
| `retire_count_i` | `input` | `input  logic [STEP_WIDTH-1:0] retire_count_i` |
| `write_ptr_o` | `output` | `output logic [ADDR_WIDTH-1:0] write_ptr_o` |
| `read_ptr_o` | `output` | `output logic [ADDR_WIDTH-1:0] read_ptr_o` |
| `full_o` | `output` | `output logic                  full_o` |
| `empty_o` | `output` | `output logic                  empty_o` |

## Integration and Use

Follow address, depth, outstanding-request, and response-order constraints exactly. Reset state does not imply initialized storage contents unless documented.

```systemverilog
circular_store #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .STEP_WIDTH(STEP_WIDTH)
) u_circular_store (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .clear_i(clear_i),
    .write_valid_i(write_valid_i),
    .write_ready_o(write_ready_o),
    .write_data_i(write_data_i),
    .read_valid_i(read_valid_i),
    .read_ready_o(read_ready_o),
    .read_addr_i(read_addr_i),
    .read_data_o(read_data_o),
    .retire_i(retire_i),
    .retire_count_i(retire_count_i),
    .write_ptr_o(write_ptr_o),
    .read_ptr_o(read_ptr_o),
    .full_o(full_o),
    .empty_o(empty_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
