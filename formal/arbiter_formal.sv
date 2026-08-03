// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module arbiter_formal;
  (* gclk *)logic       clk_i;
  logic       rst_n_i = 1'b0;
  (* anyseq *)logic [3:0] request_i;
  (* anyseq *)logic       advance_i;
  logic [3:0] grant_o;
  logic [1:0] selected_o;
  logic       valid_o;

  always_ff @(posedge clk_i) rst_n_i <= 1'b1;

  round_robin_arbiter #(
      .CLIENTS(4)
  ) u_arbiter (
      .clk_i     (clk_i),
      .rst_n_i   (rst_n_i),
      .advance_i (advance_i),
      .request_i (request_i),
      .grant_o   (grant_o),
      .selected_o(selected_o),
      .valid_o   (valid_o)
  );

  always_ff @(posedge clk_i) begin
    if (rst_n_i) begin
      assert ($onehot0(grant_o));
      assert (valid_o == (grant_o != 0));
      if (valid_o) begin
        assert (request_i[selected_o]);
        assert (grant_o[selected_o]);
      end
    end
  end
endmodule
