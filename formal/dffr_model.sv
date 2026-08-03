// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0
// Minimal formal model of the common asynchronous-reset register primitive.

module dffr #(
    parameter int DATA_WIDTH = 1
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] dat_o
);
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) dat_o <= '0;
    else dat_o <= dat_i;
  end
endmodule
