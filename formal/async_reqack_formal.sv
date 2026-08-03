// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module async_reqack_formal;
  (* gclk *)logic       clk_i;
  logic       rst_n_i = 1'b0;
  (* anyseq *)logic       src_valid_i;
  (* anyseq *)logic [7:0] src_data_i;
  (* anyseq *)logic       dst_ready_i;
  logic       src_ready_o;
  logic       dst_valid_o;
  logic [7:0] dst_data_o;
  logic [7:0] r_last_accepted_data;
  logic [7:0] r_accept_count;
  logic [7:0] r_deliver_count;

  async_reqack #(
      .DATA_WIDTH (8),
      .SYNC_STAGES(2)
  ) u_mailbox (
      .src_clk_i  (clk_i),
      .src_rst_n_i(rst_n_i),
      .src_valid_i(src_valid_i),
      .src_ready_o(src_ready_o),
      .src_data_i (src_data_i),
      .dst_clk_i  (clk_i),
      .dst_rst_n_i(rst_n_i),
      .dst_valid_o(dst_valid_o),
      .dst_ready_i(dst_ready_i),
      .dst_data_o (dst_data_o)
  );

  always_ff @(posedge clk_i) begin
    if (!rst_n_i) begin
      rst_n_i              <= 1'b1;
      r_last_accepted_data <= '0;
      r_accept_count       <= '0;
      r_deliver_count      <= '0;
    end else begin
      if (src_valid_i && src_ready_o) begin
        r_last_accepted_data <= src_data_i;
        r_accept_count       <= r_accept_count + 1'b1;
      end
      if (dst_valid_o && dst_ready_i) begin
        r_deliver_count <= r_deliver_count + 1'b1;
      end
    end
  end

  always_ff @(posedge clk_i) begin
    if (rst_n_i) begin
      assert (r_deliver_count <= r_accept_count);
      if (dst_valid_o && dst_ready_i) assert (dst_data_o == r_last_accepted_data);
    end
  end
endmodule
