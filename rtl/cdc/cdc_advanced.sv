// Copyright 2018-2020 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy at
// http://solderpad.org/licenses/SHL-0.51.
// SPDX-License-Identifier: SHL-0.51
//
// Original concepts include four-phase mailboxes, edge propagation,
// clearable CDCs, and isochronous handshakes.
// Derived design work: Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// Design independently implemented for common; see NOTICE for attribution.

// Public four-phase mailbox API. The underlying common primitive retains the
// payload and combines endpoint resets into one reset epoch, therefore no
// unilateral reset can create a stale delivery.
module four_phase_mailbox #(
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
  async_reqack #(
      .DATA_WIDTH (DATA_WIDTH),
      .SYNC_STAGES(SYNC_STAGES)
  ) u_mailbox (
      .src_clk_i,
      .src_rst_n_i,
      .src_valid_i,
      .src_ready_o,
      .src_data_i,
      .dst_clk_i,
      .dst_rst_n_i,
      .dst_valid_o,
      .dst_ready_i,
      .dst_data_o
  );
endmodule

// A pulse-style asynchronous event channel. Source events are accepted only
// while source_ready_o is high; this prevents silent event loss. Destination
// valid is consumed internally and event_o is exactly one destination clock.
module cdc_event_bridge #(
    parameter int SYNC_STAGES = 2
) (
    input  logic src_clk_i,
    input  logic src_rst_n_i,
    input  logic event_i,
    output logic source_ready_o,
    output logic source_busy_o,
    input  logic dst_clk_i,
    input  logic dst_rst_n_i,
    output logic event_o
);
  logic s_dst_valid;
  logic s_dst_data;

  async_reqack #(
      .DATA_WIDTH (1),
      .SYNC_STAGES(SYNC_STAGES)
  ) u_event_mailbox (
      .src_clk_i,
      .src_rst_n_i,
      .src_valid_i(event_i),
      .src_ready_o(source_ready_o),
      .src_data_i (1'b1),
      .dst_clk_i,
      .dst_rst_n_i,
      .dst_valid_o(s_dst_valid),
      .dst_ready_i(1'b1),
      .dst_data_o (s_dst_data)
  );
  assign event_o       = s_dst_valid && s_dst_data;
  assign source_busy_o = !source_ready_o;
endmodule

// The acknowledgement-oriented event API exposes completion at the source.
module cdc_event_bridge_ack #(
    parameter int SYNC_STAGES = 2
) (
    input  logic src_clk_i,
    input  logic src_rst_n_i,
    input  logic event_i,
    output logic accepted_o,
    output logic completed_o,
    input  logic dst_clk_i,
    input  logic dst_rst_n_i,
    output logic event_o
);
  logic s_ready;
  logic r_waiting;

  cdc_event_bridge #(
      .SYNC_STAGES(SYNC_STAGES)
  ) u_bridge (
      .src_clk_i,
      .src_rst_n_i,
      .event_i       (event_i && s_ready),
      .source_ready_o(s_ready),
      .source_busy_o (),
      .dst_clk_i,
      .dst_rst_n_i,
      .event_o
  );
  assign accepted_o  = event_i && s_ready;
  assign completed_o = r_waiting && s_ready;

  always_ff @(posedge src_clk_i or negedge src_rst_n_i) begin
    if (!src_rst_n_i) r_waiting <= 1'b0;
    else if (accepted_o) r_waiting <= 1'b1;
    else if (r_waiting && s_ready) r_waiting <= 1'b0;
  end
endmodule

// A naming-distinct two-phase queue API. The established Gray-pointer FIFO is
// used because it offers the same ordered, bounded asynchronous queue contract
// with safer reset recovery than a raw pointer-toggle implementation.
module two_phase_async_queue #(
    parameter int DATA_WIDTH  = 32,
    parameter int DEPTH       = 8,
    parameter int SYNC_STAGES = 2
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
      .BUFFER_DEPTH(DEPTH),
      .SYNC_STAGES (SYNC_STAGES)
  ) u_queue (
      .src_clk_i,
      .src_rst_n_i,
      .src_data_i,
      .src_valid_i,
      .src_ready_o,
      .dst_clk_i,
      .dst_rst_n_i,
      .dst_data_o,
      .dst_valid_o,
      .dst_ready_i
  );
endmodule

// A destination-originated clear is retained by a four-phase mailbox before it
// reaches the source-side flush coordinator. This is deliberately not a raw
// synchronizer: a one-cycle destination clear pulse must not be lost when the
// source clock is slower or phase-shifted.
module cdc_remote_clear_request #(
    parameter int SYNC_STAGES = 3
) (
    input  logic request_clk_i,
    input  logic request_rst_n_i,
    input  logic request_i,
    output logic request_busy_o,
    input  logic accept_clk_i,
    input  logic accept_rst_n_i,
    output logic accept_valid_o,
    input  logic accept_ready_i
);
  logic r_request_pending;
  logic r_request_seen;
  logic s_request_ready;
  logic s_request_data;

  async_reqack #(
      .DATA_WIDTH (1),
      .SYNC_STAGES(SYNC_STAGES)
  ) u_request_mailbox (
      .src_clk_i  (request_clk_i),
      .src_rst_n_i(request_rst_n_i),
      .src_valid_i(r_request_pending),
      .src_ready_o(s_request_ready),
      .src_data_i (1'b1),
      .dst_clk_i  (accept_clk_i),
      .dst_rst_n_i(accept_rst_n_i),
      .dst_valid_o(accept_valid_o),
      .dst_ready_i(accept_ready_i),
      .dst_data_o (s_request_data)
  );

  always_ff @(posedge request_clk_i or negedge request_rst_n_i) begin
    if (!request_rst_n_i) begin
      r_request_pending <= 1'b0;
      r_request_seen    <= 1'b0;
    end else begin
      if (r_request_pending && s_request_ready) r_request_pending <= 1'b0;
      if (!request_i) begin
        r_request_seen <= 1'b0;
      end else if (!r_request_seen) begin
        r_request_seen <= 1'b1;
        if (r_request_pending || !s_request_ready) begin
`ifndef SYNTHESIS
          $fatal(1, "cdc_remote_clear_request: request asserted while busy");
`endif
        end else begin
          r_request_pending <= 1'b1;
        end
      end
    end
  end

  assign request_busy_o = r_request_pending || !s_request_ready;

  initial begin
    if (SYNC_STAGES < 2) $fatal(1, "cdc_remote_clear_request: SYNC_STAGES must be at least two");
  end
endmodule

// Both endpoints may request a coordinated clear. A clear is an abort: data
// accepted before the request can be discarded, but post-clear data cannot be
// duplicated or interpreted as pre-clear data. Clear inputs are edge-detected
// request events and must be asserted only while the corresponding busy output
// is low.
module clearable_two_phase_link #(
    parameter int DATA_WIDTH  = 32,
    parameter int SYNC_STAGES = 3
) (
    input  logic                  src_clk_i,
    input  logic                  src_rst_n_i,
    input  logic                  src_clear_i,
    output logic                  src_clear_busy_o,
    input  logic [DATA_WIDTH-1:0] src_data_i,
    input  logic                  src_valid_i,
    output logic                  src_ready_o,
    input  logic                  dst_clk_i,
    input  logic                  dst_rst_n_i,
    input  logic                  dst_clear_i,
    output logic                  dst_clear_busy_o,
    output logic [DATA_WIDTH-1:0] dst_data_o,
    output logic                  dst_valid_o,
    input  logic                  dst_ready_i
);
  logic s_remote_clear_valid;
  logic s_remote_clear_busy;
  logic s_flush_clear;
  logic s_src_isolate;
  logic s_src_reset;
  logic s_src_busy;
  logic s_dst_isolate;
  logic s_dst_reset;
  logic s_dst_busy;
  logic s_raw_ready;
  logic s_raw_valid;

  cdc_remote_clear_request #(
      .SYNC_STAGES(SYNC_STAGES)
  ) u_remote_clear_request (
      .request_clk_i  (dst_clk_i),
      .request_rst_n_i(dst_rst_n_i),
      .request_i      (dst_clear_i),
      .request_busy_o (s_remote_clear_busy),
      .accept_clk_i   (src_clk_i),
      .accept_rst_n_i (src_rst_n_i),
      .accept_valid_o (s_remote_clear_valid),
      .accept_ready_i (!s_src_busy && !src_clear_i)
  );
  assign s_flush_clear = src_clear_i || s_remote_clear_valid;
  cdc_warm_flush_controller #(
      .SYNC_STAGES(SYNC_STAGES)
  ) u_flush_controller (
      .src_clk_i,
      .src_rst_n_i,
      .src_clear_i  (s_flush_clear),
      .src_isolate_o(s_src_isolate),
      .src_reset_o  (s_src_reset),
      .src_busy_o   (s_src_busy),
      .dst_clk_i,
      .dst_rst_n_i,
      .dst_isolate_o(s_dst_isolate),
      .dst_reset_o  (s_dst_reset),
      .dst_busy_o   (s_dst_busy)
  );
  cdc_2phase #(
      .DATA_WIDTH (DATA_WIDTH),
      .SYNC_STAGES(SYNC_STAGES)
  ) u_link (
      .src_clk_i,
      .src_rst_n_i(src_rst_n_i && !s_src_reset),
      .src_data_i,
      .src_valid_i(src_valid_i && !s_src_isolate && !src_clear_i),
      .src_ready_o(s_raw_ready),
      .dst_clk_i,
      .dst_rst_n_i(dst_rst_n_i && !s_dst_reset),
      .dst_data_o,
      .dst_valid_o(s_raw_valid),
      .dst_ready_i(dst_ready_i && !s_dst_isolate && !s_remote_clear_busy && !dst_clear_i)
  );
  assign src_ready_o      = s_raw_ready && !s_src_isolate && !src_clear_i;
  assign dst_valid_o      = s_raw_valid && !s_dst_isolate && !s_remote_clear_busy && !dst_clear_i;
  assign src_clear_busy_o = s_src_busy || src_clear_i;
  assign dst_clear_busy_o = s_dst_busy || s_remote_clear_busy || dst_clear_i;

  initial begin
    if (SYNC_STAGES < 3) $fatal(1, "clearable_two_phase_link: SYNC_STAGES must be at least three");
  end
endmodule

module clearable_async_queue #(
    parameter int DATA_WIDTH  = 32,
    parameter int DEPTH       = 8,
    parameter int SYNC_STAGES = 3
) (
    input  logic                  src_clk_i,
    input  logic                  src_rst_n_i,
    input  logic                  src_clear_i,
    output logic                  src_clear_busy_o,
    input  logic [DATA_WIDTH-1:0] src_data_i,
    input  logic                  src_valid_i,
    output logic                  src_ready_o,
    input  logic                  dst_clk_i,
    input  logic                  dst_rst_n_i,
    input  logic                  dst_clear_i,
    output logic                  dst_clear_busy_o,
    output logic [DATA_WIDTH-1:0] dst_data_o,
    output logic                  dst_valid_o,
    input  logic                  dst_ready_i
);
  logic s_remote_clear_valid;
  logic s_remote_clear_busy;
  logic s_flush_clear;
  logic s_src_isolate;
  logic s_src_reset;
  logic s_src_busy;
  logic s_dst_isolate;
  logic s_dst_reset;
  logic s_dst_busy;
  logic s_raw_ready;
  logic s_raw_valid;

  cdc_remote_clear_request #(
      .SYNC_STAGES(SYNC_STAGES)
  ) u_remote_clear_request (
      .request_clk_i  (dst_clk_i),
      .request_rst_n_i(dst_rst_n_i),
      .request_i      (dst_clear_i),
      .request_busy_o (s_remote_clear_busy),
      .accept_clk_i   (src_clk_i),
      .accept_rst_n_i (src_rst_n_i),
      .accept_valid_o (s_remote_clear_valid),
      .accept_ready_i (!s_src_busy && !src_clear_i)
  );
  assign s_flush_clear = src_clear_i || s_remote_clear_valid;
  cdc_warm_flush_controller #(
      .SYNC_STAGES(SYNC_STAGES)
  ) u_flush_controller (
      .src_clk_i,
      .src_rst_n_i,
      .src_clear_i  (s_flush_clear),
      .src_isolate_o(s_src_isolate),
      .src_reset_o  (s_src_reset),
      .src_busy_o   (s_src_busy),
      .dst_clk_i,
      .dst_rst_n_i,
      .dst_isolate_o(s_dst_isolate),
      .dst_reset_o  (s_dst_reset),
      .dst_busy_o   (s_dst_busy)
  );
  cdc_fifo #(
      .DATA_WIDTH  (DATA_WIDTH),
      .BUFFER_DEPTH(DEPTH),
      .SYNC_STAGES (SYNC_STAGES)
  ) u_queue (
      .src_clk_i,
      .src_rst_n_i(src_rst_n_i && !s_src_reset),
      .src_data_i,
      .src_valid_i(src_valid_i && !s_src_isolate && !src_clear_i),
      .src_ready_o(s_raw_ready),
      .dst_clk_i,
      .dst_rst_n_i(dst_rst_n_i && !s_dst_reset),
      .dst_data_o,
      .dst_valid_o(s_raw_valid),
      .dst_ready_i(dst_ready_i && !s_dst_isolate && !s_remote_clear_busy && !dst_clear_i)
  );
  assign src_ready_o      = s_raw_ready && !s_src_isolate && !src_clear_i;
  assign dst_valid_o      = s_raw_valid && !s_dst_isolate && !s_remote_clear_busy && !dst_clear_i;
  assign src_clear_busy_o = s_src_busy || src_clear_i;
  assign dst_clear_busy_o = s_dst_busy || s_remote_clear_busy || dst_clear_i;

  initial begin
    if (SYNC_STAGES < 3) $fatal(1, "clearable_async_queue: SYNC_STAGES must be at least three");
  end
endmodule

// For clock domains with a fixed integer frequency relation and STA coverage.
// It is not an asynchronous CDC and must never be used for unrelated clocks.
module isochronous_handshake (
    input  logic src_clk_i,
    input  logic src_rst_n_i,
    input  logic src_valid_i,
    output logic src_ready_o,
    input  logic dst_clk_i,
    input  logic dst_rst_n_i,
    output logic dst_valid_o,
    input  logic dst_ready_i
);
  logic r_src_toggle;
  logic r_dst_seen;
  logic r_dst_toggle;
  logic r_src_seen;

  always_ff @(posedge src_clk_i or negedge src_rst_n_i) begin
    if (!src_rst_n_i) begin
      r_src_toggle <= 1'b0;
      r_src_seen   <= 1'b0;
    end else begin
      r_src_seen <= r_dst_toggle;
      if (src_valid_i && src_ready_o) r_src_toggle <= ~r_src_toggle;
    end
  end
  always_ff @(posedge dst_clk_i or negedge dst_rst_n_i) begin
    if (!dst_rst_n_i) begin
      r_dst_seen   <= 1'b0;
      r_dst_toggle <= 1'b0;
    end else begin
      r_dst_seen <= r_src_toggle;
      if (dst_valid_o && dst_ready_i) r_dst_toggle <= ~r_dst_toggle;
    end
  end
  assign src_ready_o = (r_src_toggle == r_src_seen);
  assign dst_valid_o = (r_dst_seen != r_dst_toggle);
endmodule

module isochronous_stream_buffer #(
    parameter int DATA_WIDTH = 32,
    parameter bit BYPASS     = 1'b0
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
  if (BYPASS) begin : GEN_BYPASS
    assign src_ready_o = dst_ready_i;
    assign dst_valid_o = src_valid_i;
    assign dst_data_o  = src_data_i;
  end else begin : GEN_BUFFER
    logic [           1:0] r_write_ptr;
    logic [           1:0] r_read_ptr;
    logic [DATA_WIDTH-1:0] r_storage   [0:1];
    logic [           1:0] s_distance;

    assign s_distance  = r_write_ptr ^ r_read_ptr;
    assign src_ready_o = (s_distance != 2'b10);
    assign dst_valid_o = (s_distance != '0);
    assign dst_data_o  = r_storage[r_read_ptr[0]];
    always_ff @(posedge src_clk_i or negedge src_rst_n_i) begin
      if (!src_rst_n_i) r_write_ptr <= '0;
      else if (src_valid_i && src_ready_o) begin
        r_storage[r_write_ptr[0]] <= src_data_i;
        r_write_ptr               <= r_write_ptr + 1'b1;
      end
    end
    always_ff @(posedge dst_clk_i or negedge dst_rst_n_i) begin
      if (!dst_rst_n_i) r_read_ptr <= '0;
      else if (dst_valid_o && dst_ready_i) r_read_ptr <= r_read_ptr + 1'b1;
    end
  end

  initial begin
    if (DATA_WIDTH < 1) $fatal(1, "isochronous_stream_buffer: DATA_WIDTH must be positive");
  end
endmodule

module synchronized_edge #(
    parameter int SYNC_STAGES = 2
) (
    input  logic clk_i,
    input  logic rst_n_i,
    input  logic clear_i,
    input  logic enable_i,
    input  logic async_level_i,
    output logic level_o,
    output logic rise_o,
    output logic fall_o
);
  logic s_synced;
  logic r_previous;
  cdc_sync #(
      .STAGE(SYNC_STAGES)
  ) u_sync (
      .clk_i,
      .rst_n_i,
      .dat_i(async_level_i),
      .dat_o(s_synced)
  );
  assign level_o = r_previous;
  assign rise_o  = enable_i && s_synced && !r_previous;
  assign fall_o  = enable_i && !s_synced && r_previous;
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i || clear_i) r_previous <= 1'b0;
    else if (enable_i) r_previous <= s_synced;
  end
  initial begin
    if (SYNC_STAGES < 2) $fatal(1, "synchronized_edge: SYNC_STAGES must be at least two");
  end
endmodule

module test_reset_synchronizer #(
    parameter int STAGES = 3
) (
    input  logic clk_i,
    input  logic functional_rst_n_i,
    input  logic test_rst_n_i,
    input  logic test_mode_i,
    output logic rst_n_o,
    output logic init_n_o
);
  logic s_selected_rst_n;
  logic s_synced_rst_n;
  assign s_selected_rst_n = test_mode_i ? test_rst_n_i : functional_rst_n_i;
  rst_sync #(
      .STAGE(STAGES)
  ) u_sync (
      .clk_i,
      .rst_n_i(s_selected_rst_n),
      .rst_n_o(s_synced_rst_n)
  );
  assign rst_n_o  = test_mode_i ? test_rst_n_i : s_synced_rst_n;
  assign init_n_o = test_mode_i ? 1'b1 : s_synced_rst_n;
  initial begin
    if (STAGES < 2) $fatal(1, "test_reset_synchronizer: STAGES must be at least two");
  end
endmodule
