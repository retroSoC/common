# counting_bloom_filter

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/base/hash_cells.sv`](../../../rtl/base/hash_cells.sv) |
| Availability | Synthesizable RTL |

## Summary

Counting Bloom filter with explicit counter saturation.

## Functional Behavior

Counting Bloom filter with explicit counter saturation. It is a self-contained base primitive with the behavior and parameter checks implemented in the linked RTL source.

## Suitable Applications

Use as a structured building block for control, encoding, ECC, hashing, masking, replacement, or observability logic.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int          DATA_WIDTH   = 32` |
| `HASH_WIDTH` | `parameter int          HASH_WIDTH   = 5` |
| `HASHES` | `parameter int          HASHES       = 3` |
| `BUCKET_WIDTH` | `parameter int          BUCKET_WIDTH = 4` |
| `ROUNDS` | `parameter int          ROUNDS       = 2` |
| `SEED` | `parameter logic [31:0] SEED         = 32'hC0DE_1234` |

## Interface Definition

```systemverilog
module counting_bloom_filter #(
    parameter int          DATA_WIDTH   = 32,
    parameter int          HASH_WIDTH   = 5,
    parameter int          HASHES       = 3,
    parameter int          BUCKET_WIDTH = 4,
    parameter int          ROUNDS       = 2,
    parameter logic [31:0] SEED         = 32'hC0DE_1234
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  clear_i,
    input  logic [DATA_WIDTH-1:0] lookup_data_i,
    output logic                  member_o,
    input  logic [DATA_WIDTH-1:0] insert_data_i,
    input  logic                  insert_i,
    input  logic [DATA_WIDTH-1:0] remove_data_i,
    input  logic                  remove_i,
    output logic [  HASH_WIDTH:0] usage_o,
    output logic                  empty_o,
    output logic                  full_o,
    output logic                  saturated_o
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                  clk_i` |
| `rst_n_i` | `input` | `input  logic                  rst_n_i` |
| `clear_i` | `input` | `input  logic                  clear_i` |
| `lookup_data_i` | `input` | `input  logic [DATA_WIDTH-1:0] lookup_data_i` |
| `member_o` | `output` | `output logic                  member_o` |
| `insert_data_i` | `input` | `input  logic [DATA_WIDTH-1:0] insert_data_i` |
| `insert_i` | `input` | `input  logic                  insert_i` |
| `remove_data_i` | `input` | `input  logic [DATA_WIDTH-1:0] remove_data_i` |
| `remove_i` | `input` | `input  logic                  remove_i` |
| `usage_o` | `output` | `output logic [  HASH_WIDTH:0] usage_o` |
| `empty_o` | `output` | `output logic                  empty_o` |
| `full_o` | `output` | `output logic                  full_o` |
| `saturated_o` | `output` | `output logic                  saturated_o` |

## Integration and Use

Honor validity/error outputs and parameter constraints. Combinational cells do not provide timing isolation or CDC protection.

```systemverilog
counting_bloom_filter #(
    .DATA_WIDTH(DATA_WIDTH),
    .HASH_WIDTH(HASH_WIDTH),
    .HASHES(HASHES),
    .BUCKET_WIDTH(BUCKET_WIDTH),
    .ROUNDS(ROUNDS),
    .SEED(SEED)
) u_counting_bloom_filter (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .clear_i(clear_i),
    .lookup_data_i(lookup_data_i),
    .member_o(member_o),
    .insert_data_i(insert_data_i),
    .insert_i(insert_i),
    .remove_data_i(remove_data_i),
    .remove_i(remove_i),
    .usage_o(usage_o),
    .empty_o(empty_o),
    .full_o(full_o),
    .saturated_o(saturated_o)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
