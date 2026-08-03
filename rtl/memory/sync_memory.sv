// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0
// Portable positive-logic synchronous memory used by new common components.
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
  logic [DATA_WIDTH-1:0] r_storage[0:DEPTH-1];
  initial begin
    if (DATA_WIDTH < 1 || DEPTH < 1) $fatal(1, "sync_memory: invalid geometry");
  end
  always_ff @(posedge clk_i) begin
    if (write_enable_i) r_storage[addr_i] <= write_data_i;
    if (read_enable_i) read_data_o <= r_storage[addr_i];
  end
endmodule
