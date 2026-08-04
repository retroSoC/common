# memory_bank_adapter

| Property | Value |
| --- | --- |
| Kind | `module` |
| RTL source | [`rtl/memory/data_structures.sv`](../../../rtl/memory/data_structures.sv) |
| Availability | Synthesizable RTL |

## Summary

Public banked-memory request and response adapter.

## Functional Behavior

Public banked-memory request and response adapter. It implements the declared storage, ordering, banking, or response contract with explicit bounds rather than silently dropping malformed transactions.

## Suitable Applications

Use for local queues, reorder structures, banked stores, and portable memory-backed blocks.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `ADDR_WIDTH` | `parameter int ADDR_WIDTH = 32` |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 32` |
| `BANKS` | `parameter int BANKS      = 2` |

## Interface Definition

```systemverilog
module memory_bank_adapter #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int BANKS      = 2
) (
    input  logic                                              clk_i,
    input  logic                                              rst_n_i,
    input  logic                                              clear_i,
    input  logic                                              request_valid_i,
    output logic                                              request_ready_o,
    input  logic [  ADDR_WIDTH-1:0]                           request_addr_i,
    input  logic [  DATA_WIDTH-1:0]                           request_write_data_i,
    input  logic [DATA_WIDTH/8-1:0]                           request_strobe_i,
    input  logic                                              request_write_i,
    output logic                                              response_valid_o,
    input  logic                                              response_ready_i,
    output logic [  DATA_WIDTH-1:0]                           response_data_o,
    output logic [       BANKS-1:0]                           bank_request_valid_o,
    input  logic [       BANKS-1:0]                           bank_request_ready_i,
    output logic [       BANKS-1:0][          ADDR_WIDTH-1:0] bank_addr_o,
    output logic [       BANKS-1:0][    DATA_WIDTH/BANKS-1:0] bank_write_data_o,
    output logic [       BANKS-1:0][DATA_WIDTH/(8*BANKS)-1:0] bank_strobe_o,
    output logic [       BANKS-1:0]                           bank_write_o,
    input  logic [       BANKS-1:0]                           bank_response_valid_i,
    output logic [       BANKS-1:0]                           bank_response_ready_o,
    input  logic [       BANKS-1:0][    DATA_WIDTH/BANKS-1:0] bank_response_data_i
);
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input  logic                                              clk_i` |
| `rst_n_i` | `input` | `input  logic                                              rst_n_i` |
| `clear_i` | `input` | `input  logic                                              clear_i` |
| `request_valid_i` | `input` | `input  logic                                              request_valid_i` |
| `request_ready_o` | `output` | `output logic                                              request_ready_o` |
| `request_addr_i` | `input` | `input  logic [  ADDR_WIDTH-1:0]                           request_addr_i` |
| `request_write_data_i` | `input` | `input  logic [  DATA_WIDTH-1:0]                           request_write_data_i` |
| `request_strobe_i` | `input` | `input  logic [DATA_WIDTH/8-1:0]                           request_strobe_i` |
| `request_write_i` | `input` | `input  logic                                              request_write_i` |
| `response_valid_o` | `output` | `output logic                                              response_valid_o` |
| `response_ready_i` | `input` | `input  logic                                              response_ready_i` |
| `response_data_o` | `output` | `output logic [  DATA_WIDTH-1:0]                           response_data_o` |
| `bank_request_valid_o` | `output` | `output logic [       BANKS-1:0]                           bank_request_valid_o` |
| `bank_request_ready_i` | `input` | `input  logic [       BANKS-1:0]                           bank_request_ready_i` |
| `bank_addr_o` | `output` | `output logic [       BANKS-1:0][          ADDR_WIDTH-1:0] bank_addr_o` |
| `bank_write_data_o` | `output` | `output logic [       BANKS-1:0][    DATA_WIDTH/BANKS-1:0] bank_write_data_o` |
| `bank_strobe_o` | `output` | `output logic [       BANKS-1:0][DATA_WIDTH/(8*BANKS)-1:0] bank_strobe_o` |
| `bank_write_o` | `output` | `output logic [       BANKS-1:0]                           bank_write_o` |
| `bank_response_valid_i` | `input` | `input  logic [       BANKS-1:0]                           bank_response_valid_i` |
| `bank_response_ready_o` | `output` | `output logic [       BANKS-1:0]                           bank_response_ready_o` |
| `bank_response_data_i` | `input` | `input  logic [       BANKS-1:0][    DATA_WIDTH/BANKS-1:0] bank_response_data_i` |

## Integration and Use

Follow address, depth, outstanding-request, and response-order constraints exactly. Reset state does not imply initialized storage contents unless documented.

```systemverilog
memory_bank_adapter #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .BANKS(BANKS)
) u_memory_bank_adapter (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .clear_i(clear_i),
    .request_valid_i(request_valid_i),
    .request_ready_o(request_ready_o),
    .request_addr_i(request_addr_i),
    .request_write_data_i(request_write_data_i),
    .request_strobe_i(request_strobe_i),
    .request_write_i(request_write_i),
    .response_valid_o(response_valid_o),
    .response_ready_i(response_ready_i),
    .response_data_o(response_data_o),
    .bank_request_valid_o(bank_request_valid_o),
    .bank_request_ready_i(bank_request_ready_i),
    .bank_addr_o(bank_addr_o),
    .bank_write_data_o(bank_write_data_o),
    .bank_strobe_o(bank_strobe_o),
    .bank_write_o(bank_write_o),
    .bank_response_valid_i(bank_response_valid_i),
    .bank_response_ready_o(bank_response_ready_o),
    .bank_response_data_i(bank_response_data_i)
);
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
