// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module stream_queue_formal;
  (* gclk *)logic       clk_i;
  logic       rst_n_i = 1'b0;
  (* anyseq *)logic       flush_i;
  (* anyseq *)logic       in_valid_i;
  logic       in_ready_o;
  (* anyseq *)logic [7:0] in_data_i;
  logic       out_valid_o;
  (* anyseq *)logic       out_ready_i;
  logic [7:0] out_data_o;
  logic [1:0] usage_o;
  logic       f_past_valid = 1'b0;

  always_ff @(posedge clk_i) begin
    rst_n_i      <= 1'b1;
    f_past_valid <= 1'b1;
  end

  stream_queue #(
      .DATA_WIDTH  (8),
      .DEPTH       (2),
      .FALL_THROUGH(1'b0)
  ) u_queue (
      .clk_i,
      .rst_n_i,
      .flush_i,
      .in_valid_i,
      .in_ready_o,
      .in_data_i,
      .out_valid_o,
      .out_ready_i,
      .out_data_o,
      .usage_o
  );

  // The direct pass-through path relies on the standard ready/valid source
  // contract: a stalled source retains valid and its payload.
  always_ff @(posedge clk_i) begin
    if (f_past_valid && $past(
            rst_n_i
        ) && !$past(
            flush_i
        ) && !flush_i && $past(
            in_valid_i && !in_ready_o
        )) begin
      assume (in_valid_i);
      assume (in_data_i == $past(in_data_i));
    end
  end

  always_ff @(posedge clk_i) begin
    if (f_past_valid && $past(rst_n_i) && !$past(flush_i) && !flush_i) begin
      assert (usage_o <= 2);
      if ($past(out_valid_o && !out_ready_i)) begin
        assert (out_valid_o);
        assert (out_data_o == $past(out_data_o));
      end
    end
  end
endmodule
