// Copyright 2018-2024 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51. You may obtain a copy at
// http://solderpad.org/licenses/SHL-0.51.
//
// Derived design work: Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: SHL-0.51
// Design independently implemented for common; see NOTICE for attribution.

// Glitch-free only when select_i changes after both source clocks are running;
// the enables are updated on falling edges, so neither high pulse is truncated.
module safe_clock_mux (
    input  logic clk0_i,
    input  logic clk1_i,
    input  logic rst_n_i,
    input  logic select_i,
    output logic clk_o
);
  logic r_enable0;
  logic r_enable1;

  always_ff @(negedge clk0_i or negedge rst_n_i) begin
    if (!rst_n_i) r_enable0 <= 1'b0;
    else r_enable0 <= !select_i && !r_enable1;
  end

  always_ff @(negedge clk1_i or negedge rst_n_i) begin
    if (!rst_n_i) r_enable1 <= 1'b0;
    else r_enable1 <= select_i && !r_enable0;
  end

  assign clk_o = (clk0_i && r_enable0) || (clk1_i && r_enable1);
endmodule
