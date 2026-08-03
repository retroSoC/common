// Copyright 2018-2024 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51. You may obtain a copy at
// http://solderpad.org/licenses/SHL-0.51.
//
// Derived design work: Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: SHL-0.51
// Design independently implemented for common; see NOTICE for attribution.

// The select request is first synchronized to clk0 and then forwarded to clk1,
// giving both domains one ordered request stream. Enables change only on
// falling edges after a synchronized observation that the other side is off.
// Both input clocks must run until a selection handover has completed.
module safe_clock_mux (
    input  logic clk0_i,
    input  logic clk1_i,
    input  logic rst_n_i,
    input  logic select_i,
    output logic clk_o
);
  logic r_enable0;
  logic r_enable1;
  logic s_select_clk0;
  logic s_select_clk1;
  logic s_enable0_clk1;
  logic s_enable1_clk0;

  cdc_sync u_select_clk0 (
      .clk_i  (clk0_i),
      .rst_n_i(rst_n_i),
      .dat_i  (select_i),
      .dat_o  (s_select_clk0)
  );
  cdc_sync u_select_clk1 (
      .clk_i  (clk1_i),
      .rst_n_i(rst_n_i),
      .dat_i  (s_select_clk0),
      .dat_o  (s_select_clk1)
  );
  cdc_sync u_enable0_clk1 (
      .clk_i  (clk1_i),
      .rst_n_i(rst_n_i),
      .dat_i  (r_enable0),
      .dat_o  (s_enable0_clk1)
  );
  cdc_sync u_enable1_clk0 (
      .clk_i  (clk0_i),
      .rst_n_i(rst_n_i),
      .dat_i  (r_enable1),
      .dat_o  (s_enable1_clk0)
  );

  always_ff @(negedge clk0_i or negedge rst_n_i) begin
    if (!rst_n_i) r_enable0 <= 1'b0;
    else r_enable0 <= !s_select_clk0 && !s_enable1_clk0;
  end

  always_ff @(negedge clk1_i or negedge rst_n_i) begin
    if (!rst_n_i) r_enable1 <= 1'b0;
    else r_enable1 <= s_select_clk1 && !s_enable0_clk1;
  end

  assign clk_o = (clk0_i && r_enable0) || (clk1_i && r_enable1);
endmodule
