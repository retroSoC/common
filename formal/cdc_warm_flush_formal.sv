// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

// A representative same-clock proof harness. It checks the control epochs and
// exact-once recovery behavior; physical asynchronous timing remains covered by
// the asynchronous simulator regression and structural CDC review.
module cdc_warm_flush_formal;
  (* gclk *)logic       clk_i;
  logic       rst_n_i = 1'b0;
  logic [4:0] r_phase;
  logic [7:0] src_data_i;
  logic       src_valid_i;
  logic       src_ready_o;
  logic       src_clear_i;
  logic       src_busy_o;
  logic [7:0] dst_data_o;
  logic       dst_valid_o;
  logic       dst_ready_i;
  logic       dst_busy_o;
  logic [1:0] r_deliveries;

  cdc_2phase_warm_flush #(
      .DATA_WIDTH (8),
      .SYNC_STAGES(2)
  ) u_cdc (
      .src_clk_i       (clk_i),
      .src_rst_n_i     (rst_n_i),
      .src_clear_i     (src_clear_i),
      .src_clear_busy_o(src_busy_o),
      .src_data_i      (src_data_i),
      .src_valid_i     (src_valid_i),
      .src_ready_o     (src_ready_o),
      .dst_clk_i       (clk_i),
      .dst_rst_n_i     (rst_n_i),
      .dst_clear_busy_o(dst_busy_o),
      .dst_data_o      (dst_data_o),
      .dst_valid_o     (dst_valid_o),
      .dst_ready_i     (dst_ready_i)
  );

  always_ff @(posedge clk_i) begin
    if (!rst_n_i) begin
      rst_n_i      <= 1'b1;
      r_phase      <= '0;
      src_data_i   <= '0;
      src_valid_i  <= 1'b0;
      src_clear_i  <= 1'b0;
      dst_ready_i  <= 1'b0;
      r_deliveries <= '0;
    end else begin
      src_valid_i <= 1'b0;
      src_clear_i <= 1'b0;
      if (dst_valid_o && dst_ready_i) r_deliveries <= r_deliveries + 1'b1;
      if (src_busy_o) assert (!src_ready_o);

      unique case (r_phase)
        0:
        if (src_ready_o) begin
          src_data_i  <= 8'ha1;
          src_valid_i <= 1'b1;
          r_phase     <= 1;
        end
        1:       r_phase <= 2;
        2:
        if (dst_valid_o) begin
          src_clear_i <= 1'b1;
          r_phase     <= 3;
        end
        3:       if (src_busy_o) r_phase <= 4;
        4:
        if (!src_busy_o && !dst_busy_o) begin
          dst_ready_i <= 1'b1;
          r_phase     <= 5;
        end
        5: begin
          assert (r_deliveries == '0);
          if (src_ready_o) begin
            src_data_i  <= 8'hc3;
            src_valid_i <= 1'b1;
            r_phase     <= 6;
          end
        end
        6:       r_phase <= 7;
        7:
        if (dst_valid_o) begin
          assert (dst_data_o == 8'hc3);
          r_phase <= 8;
        end
        8:       assert (r_deliveries <= 1);
        default: r_phase <= r_phase;
      endcase
    end
  end
endmodule
