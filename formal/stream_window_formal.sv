// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module stream_window_formal;
  (* gclk *)logic       clk_i;
  logic       rst_n_i = 1'b0;
  (* anyseq *)logic       flush_i;
  (* anyseq *)logic [1:0] limit_i;
  (* anyseq *)logic       submit_valid_i;
  (* anyseq *)logic       forward_ready_i;
  (* anyseq *)logic       retire_i;
  logic       submit_ready_o;
  logic       forward_valid_o;
  logic [1:0] used_o;

  stream_window_guard #(
      .MAX_INFLIGHT(2)
  ) u_guard (
      .clk_i          (clk_i),
      .rst_n_i        (rst_n_i),
      .flush_i        (flush_i),
      .limit_i        (limit_i),
      .submit_valid_i (submit_valid_i),
      .submit_ready_o (submit_ready_o),
      .forward_valid_o(forward_valid_o),
      .forward_ready_i(forward_ready_i),
      .retire_i       (retire_i),
      .used_o         (used_o)
  );

  always_ff @(posedge clk_i) begin
    if (!rst_n_i) begin
      rst_n_i <= 1'b1;
    end else begin
      assert (used_o <= 2);
      assert (!(submit_ready_o && !forward_ready_i));
      if (flush_i || (limit_i == '0 && used_o == '0 && !retire_i)) begin
        assert (!submit_ready_o);
      end
    end
  end
endmodule
