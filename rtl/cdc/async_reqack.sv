// Copyright 2018-2024 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51. You may obtain a copy at
// http://solderpad.org/licenses/SHL-0.51.
//
// Derived design work: Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: SHL-0.51
// Design independently implemented for common; see NOTICE for attribution.

// A four-phase, one-entry asynchronous mailbox. Data is held stable by the
// source until the destination has acknowledged it; only the request and
// acknowledgement controls cross synchronizers. Reset on either side aborts
// an in-flight item and restarts the link from the empty state.
module async_reqack #(
    parameter int DATA_WIDTH  = 32,
    parameter int SYNC_STAGES = 2
) (
    input  logic                  src_clk_i,
    input  logic                  src_rst_n_i,
    input  logic                  src_valid_i,
    output logic                  src_ready_o,
    input  logic [DATA_WIDTH-1:0] src_data_i,
    input  logic                  dst_clk_i,
    input  logic                  dst_rst_n_i,
    output logic                  dst_valid_o,
    input  logic                  dst_ready_i,
    output logic [DATA_WIDTH-1:0] dst_data_o
);
  logic [DATA_WIDTH-1:0] r_payload;
  logic                  r_request;
  logic                  r_busy;
  logic                  r_acknowledge;
  logic                  s_ack_src;
  logic                  s_req_dst;
  logic                  s_link_rst_n;
  logic                  s_src_rst_n;
  logic                  s_dst_rst_n;

  initial begin
    if (DATA_WIDTH < 1 || SYNC_STAGES < 2) begin
      $fatal(1, "async_reqack: DATA_WIDTH must be positive and SYNC_STAGES at least two");
    end
  end

  // A four-phase protocol cannot recover a unilateral reset safely: one side
  // could otherwise interpret a stale request or acknowledgement as a new
  // transaction. A reset in either domain therefore flushes the mailbox.
  assign s_link_rst_n = src_rst_n_i && dst_rst_n_i;
  cdc_reset_barrier #(
      .STAGES(SYNC_STAGES)
  ) u_reset_barrier (
      .clk_a_i  (src_clk_i),
      .clk_b_i  (dst_clk_i),
      .rst_n_i  (s_link_rst_n),
      .release_i(1'b1),
      .rst_a_n_o(s_src_rst_n),
      .rst_b_n_o(s_dst_rst_n)
  );

  cdc_sync #(
      .STAGE(SYNC_STAGES)
  ) u_ack_sync (
      .clk_i  (src_clk_i),
      .rst_n_i(s_src_rst_n),
      .dat_i  (r_acknowledge),
      .dat_o  (s_ack_src)
  );
  cdc_sync #(
      .STAGE(SYNC_STAGES)
  ) u_req_sync (
      .clk_i  (dst_clk_i),
      .rst_n_i(s_dst_rst_n),
      .dat_i  (r_request),
      .dat_o  (s_req_dst)
  );

  assign src_ready_o = s_src_rst_n && !r_busy;
  // A request stays asserted until the four-phase return-to-zero completes.
  // Suppress valid after its first destination handshake so a continuously
  // ready consumer cannot accept the same item again.
  assign dst_valid_o = s_dst_rst_n && s_req_dst && !r_acknowledge;
  assign dst_data_o  = r_payload;

  always_ff @(posedge src_clk_i or negedge s_src_rst_n) begin
    if (!s_src_rst_n) begin
      r_payload <= '0;
      r_request <= 1'b0;
      r_busy    <= 1'b0;
    end else if (!r_busy && src_valid_i) begin
      r_payload <= src_data_i;
      r_request <= 1'b1;
      r_busy    <= 1'b1;
    end else if (r_busy && r_request && s_ack_src) begin
      r_request <= 1'b0;
    end else if (r_busy && !r_request && !s_ack_src) begin
      r_busy <= 1'b0;
    end
  end

  always_ff @(posedge dst_clk_i or negedge s_dst_rst_n) begin
    if (!s_dst_rst_n) begin
      r_acknowledge <= 1'b0;
    end else begin
      if (!s_req_dst) begin
        r_acknowledge <= 1'b0;
      end else if (!r_acknowledge && dst_ready_i) begin
        r_acknowledge <= 1'b1;
      end
    end
  end
endmodule

// Named wrapper for the gray-pointer asynchronous queue. Keeping this wrapper
// avoids parallel implementations and makes the preferred public API explicit.
module async_gray_queue #(
    parameter int DATA_WIDTH   = 32,
    parameter int BUFFER_DEPTH = 8,
    parameter int SYNC_STAGES  = 2
) (
    input  logic                  src_clk_i,
    input  logic                  src_rst_n_i,
    input  logic [DATA_WIDTH-1:0] src_data_i,
    input  logic                  src_valid_i,
    output logic                  src_ready_o,
    input  logic                  dst_clk_i,
    input  logic                  dst_rst_n_i,
    output logic [DATA_WIDTH-1:0] dst_data_o,
    output logic                  dst_valid_o,
    input  logic                  dst_ready_i
);
  cdc_fifo #(
      .DATA_WIDTH  (DATA_WIDTH),
      .BUFFER_DEPTH(BUFFER_DEPTH),
      .SYNC_STAGES (SYNC_STAGES)
  ) u_cdc_fifo (
      .src_clk_i  (src_clk_i),
      .src_rst_n_i(src_rst_n_i),
      .src_data_i (src_data_i),
      .src_valid_i(src_valid_i),
      .src_ready_o(src_ready_o),
      .dst_clk_i  (dst_clk_i),
      .dst_rst_n_i(dst_rst_n_i),
      .dst_data_o (dst_data_o),
      .dst_valid_o(dst_valid_o),
      .dst_ready_i(dst_ready_i)
  );
endmodule
