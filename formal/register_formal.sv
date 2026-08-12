// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module register_formal;
  (* gclk *)logic       clk_i;
  logic       rst_n_i = 1'b0;
  (* anyseq *)logic       en_i;
  (* anyseq *)logic [3:0] dat_i;
  logic [3:0] dffsrc_o;
  logic [3:0] dffesrc_o;
  logic [3:0] dffsrc_ref;
  logic [3:0] dffesrc_ref;

  always_ff @(posedge clk_i) rst_n_i <= 1'b1;

  dffsrc #(
      .DATA_WIDTH(4),
      .RESET_VAL (4'hA)
  ) u_dffsrc (
      .clk_i  (clk_i),
      .rst_n_i(rst_n_i),
      .dat_i  (dat_i),
      .dat_o  (dffsrc_o)
  );

  dffesrc #(
      .DATA_WIDTH(4),
      .RESET_VAL (4'hB)
  ) u_dffesrc (
      .clk_i  (clk_i),
      .rst_n_i(rst_n_i),
      .en_i   (en_i),
      .dat_i  (dat_i),
      .dat_o  (dffesrc_o)
  );

  always_ff @(posedge clk_i) begin
    if (!rst_n_i) begin
      dffsrc_ref  <= 4'hA;
      dffesrc_ref <= 4'hB;
    end else begin
      dffsrc_ref <= dat_i;
      if (en_i) dffesrc_ref <= dat_i;
    end
  end

  always @(negedge clk_i) begin
    if (rst_n_i) begin
      assert (dffsrc_o == dffsrc_ref);
      assert (dffesrc_o == dffesrc_ref);
    end
  end

endmodule
