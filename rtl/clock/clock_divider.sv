// Copyright 2021 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51. You may obtain a copy at
// http://solderpad.org/licenses/SHL-0.51.
//
// Derived design work: Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: SHL-0.51
// Design independently implemented for common; see NOTICE for attribution.

// div_i is the number of input rising edges in each output half-period. A
// divide value of one therefore produces clk_i / 2. New values are accepted
// only while the output is low, preserving complete high pulses.
module clock_divider #(
    parameter int                   DIV_WIDTH = 16,
    parameter logic [DIV_WIDTH-1:0] RESET_DIV = 1
) (
    input  logic                 clk_i,
    input  logic                 rst_n_i,
    input  logic                 enable_i,
    input  logic [DIV_WIDTH-1:0] div_i,
    input  logic                 div_valid_i,
    output logic                 div_ready_o,
    output logic                 clk_o,
    output logic [DIV_WIDTH-1:0] count_o
);
  logic [DIV_WIDTH-1:0] r_divisor;
  logic [DIV_WIDTH-1:0] r_count;
  logic                 r_clock;
  logic                 s_configure;
  logic [DIV_WIDTH-1:0] s_requested_div;

  initial begin
    if (DIV_WIDTH < 1 || RESET_DIV == '0) begin
      $fatal(1, "clock_divider: division values must be non-zero");
    end
  end

  assign s_requested_div = (div_i == '0) ? {{(DIV_WIDTH - 1) {1'b0}}, 1'b1} : div_i;
  assign div_ready_o     = !enable_i || !r_clock;
  assign s_configure     = div_valid_i && div_ready_o;
  assign clk_o           = enable_i ? r_clock : 1'b0;
  assign count_o         = r_count;

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      r_divisor <= RESET_DIV;
      r_count   <= '0;
      r_clock   <= 1'b0;
    end else if (!enable_i) begin
      r_count <= '0;
      r_clock <= 1'b0;
      if (div_valid_i) r_divisor <= s_requested_div;
    end else if (s_configure) begin
      r_divisor <= s_requested_div;
      r_count   <= '0;
      r_clock   <= 1'b0;
    end else if (r_count == r_divisor - 1'b1) begin
      r_count <= '0;
      r_clock <= !r_clock;
    end else begin
      r_count <= r_count + 1'b1;
    end
  end
endmodule
