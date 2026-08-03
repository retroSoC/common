// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module fifo_formal;
  (* gclk *)logic       clk_i;
  logic       rst_n_i = 1'b0;
  (* anyseq *)logic       flush_i;
  (* anyseq *)logic       push_i;
  (* anyseq *)logic       pop_i;
  (* anyseq *)logic [7:0] dat_i;
  logic       full_o;
  logic       empty_o;
  logic [7:0] dat_o;
  logic [2:0] cnt_o;

  always_ff @(posedge clk_i) rst_n_i <= 1'b1;

  fifo #(
      .DATA_WIDTH  (8),
      .BUFFER_DEPTH(4)
  ) u_fifo (
      .clk_i  (clk_i),
      .rst_n_i(rst_n_i),
      .flush_i(flush_i),
      .push_i (push_i),
      .full_o (full_o),
      .dat_i  (dat_i),
      .pop_i  (pop_i),
      .empty_o(empty_o),
      .dat_o  (dat_o),
      .cnt_o  (cnt_o)
  );

  always_ff @(posedge clk_i) begin
    if (rst_n_i) begin
      assert (cnt_o <= 4);
      assert (!(full_o && empty_o));
      assert (empty_o == (cnt_o == 0));
      assert (full_o == (cnt_o == 4));
    end
  end
endmodule
