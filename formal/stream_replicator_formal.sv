// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module stream_replicator_formal;
  (* gclk *)logic            clk_i;
  logic            rst_n_i = 1'b0;
  (* anyseq *)logic            flush_i;
  (* anyseq *)logic            in_valid_i;
  (* anyseq *)logic [7:0]      in_data_i;
  (* anyseq *)logic [3:0]      enable_i;
  (* anyseq *)logic [3:0]      out_ready_i;
  logic            in_ready_o;
  logic [3:0]      out_valid_o;
  logic [3:0][7:0] out_data_o;
  logic [3:0]      r_expected_pending;
  logic [7:0]      r_expected_payload;

  stream_replicator #(
      .DATA_WIDTH(8),
      .PORTS     (4)
  ) u_replicator (
      .clk_i      (clk_i),
      .rst_n_i    (rst_n_i),
      .flush_i    (flush_i),
      .in_valid_i (in_valid_i),
      .in_ready_o (in_ready_o),
      .in_data_i  (in_data_i),
      .enable_i   (enable_i),
      .out_valid_o(out_valid_o),
      .out_ready_i(out_ready_i),
      .out_data_o (out_data_o)
  );

  always_ff @(posedge clk_i) begin
    if (!rst_n_i) begin
      rst_n_i            <= 1'b1;
      r_expected_pending <= '0;
      r_expected_payload <= '0;
    end else if (flush_i) begin
      r_expected_pending <= '0;
    end else if (in_valid_i && in_ready_o) begin
      r_expected_pending <= enable_i;
      r_expected_payload <= in_data_i;
    end else begin
      r_expected_pending <= r_expected_pending & ~(out_valid_o & out_ready_i);
    end
  end

  always_ff @(posedge clk_i) begin
    if (rst_n_i && !flush_i) begin
      assert (out_valid_o == r_expected_pending);
      for (int unsigned port_idx = 0; port_idx < 4; port_idx++) begin
        if (out_valid_o[port_idx]) assert (out_data_o[port_idx] == r_expected_payload);
      end
    end
  end
endmodule
