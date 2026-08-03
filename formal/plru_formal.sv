// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module plru_formal;
  (* gclk *)logic       clk_i;
  logic       rst_n_i = 1'b0;
  (* anyseq *)logic       flush_i;
  (* anyseq *)logic [3:0] touch_i;
  logic [3:0] victim_o;

  plru_victim_selector #(
      .WAYS(4)
  ) u_plru (
      .clk_i   (clk_i),
      .rst_n_i (rst_n_i),
      .flush_i (flush_i),
      .touch_i (touch_i),
      .victim_o(victim_o)
  );

  always_ff @(posedge clk_i) begin
    if (!rst_n_i) begin
      rst_n_i <= 1'b1;
    end else begin
      assume ((touch_i & (touch_i - 1'b1)) == '0);
      assert (victim_o != '0);
      assert ((victim_o & (victim_o - 1'b1)) == '0);
    end
  end
endmodule
