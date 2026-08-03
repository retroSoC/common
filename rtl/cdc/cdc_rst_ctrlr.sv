// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0
// Reset assertion is asynchronous; release is independently synchronized into
// each clock domain. release_i must remain high until both outputs are high.
module cdc_reset_barrier #(
    parameter int STAGES = 3
) (
    input  logic clk_a_i,
    input  logic clk_b_i,
    input  logic rst_n_i,
    input  logic release_i,
    output logic rst_a_n_o,
    output logic rst_b_n_o
);
  logic s_release_a;
  logic s_release_b;
  logic s_reset_a_n;
  logic s_reset_b_n;

  cdc_sync #(
      .STAGE(STAGES)
  ) u_release_a (
      .clk_i  (clk_a_i),
      .rst_n_i(rst_n_i),
      .dat_i  (release_i),
      .dat_o  (s_release_a)
  );
  cdc_sync #(
      .STAGE(STAGES)
  ) u_release_b (
      .clk_i  (clk_b_i),
      .rst_n_i(rst_n_i),
      .dat_i  (release_i),
      .dat_o  (s_release_b)
  );
  rst_sync #(
      .STAGE(STAGES)
  ) u_reset_a (
      .clk_i  (clk_a_i),
      .rst_n_i(rst_n_i),
      .rst_n_o(s_reset_a_n)
  );
  rst_sync #(
      .STAGE(STAGES)
  ) u_reset_b (
      .clk_i  (clk_b_i),
      .rst_n_i(rst_n_i),
      .rst_n_o(s_reset_b_n)
  );

  assign rst_a_n_o = s_reset_a_n && s_release_a;
  assign rst_b_n_o = s_reset_b_n && s_release_b;
endmodule
