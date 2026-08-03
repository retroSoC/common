// Copyright 2018-2024 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51. You may obtain a copy at
// http://solderpad.org/licenses/SHL-0.51.
//
// Original coordinated CDC-clear concept: Manuel Eggimann and Philippe Sauter.
// Derived design work: Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: SHL-0.51
// Design independently implemented for common; see NOTICE for attribution.

// Coordinates a source-initiated warm flush for a protected CDC primitive.
// The controller deliberately treats clear as a fast abort: the protected
// endpoints are isolated before their state is reset, and in-flight data may
// disappear. Clear requests are accepted only while src_busy_o is low.
module cdc_warm_flush_controller #(
    parameter int SYNC_STAGES = 2
) (
    input  logic src_clk_i,
    input  logic src_rst_n_i,
    input  logic src_clear_i,
    output logic src_isolate_o,
    output logic src_reset_o,
    output logic src_busy_o,

    input  logic dst_clk_i,
    input  logic dst_rst_n_i,
    output logic dst_isolate_o,
    output logic dst_reset_o,
    output logic dst_busy_o
);
  localparam logic [1:0] CMD_ISOLATE = 2'b01;
  localparam logic [1:0] CMD_RESET = 2'b10;
  localparam logic [1:0] CMD_RESUME = 2'b11;

  typedef enum logic [2:0] {
    SRC_IDLE,
    SRC_SEND_ISOLATE,
    SRC_WAIT_ISOLATE,
    SRC_SEND_RESET,
    SRC_WAIT_RESET,
    SRC_SEND_RESUME,
    SRC_WAIT_RESUME
  } src_state_t;

  logic             s_link_rst_n;
  logic             s_src_ctrl_rst_n;
  logic             s_dst_ctrl_rst_n;
  src_state_t       r_src_state;
  logic             r_src_isolate;
  logic             r_src_reset;
  logic             r_dst_isolate;
  logic             r_dst_reset;
  logic             r_dst_ack_pending;
  logic       [1:0] r_dst_ack_code;

  logic             s_command_valid;
  logic             s_command_ready;
  logic       [1:0] s_command_code;
  logic             s_command_dst_valid;
  logic             s_command_dst_ready;
  logic       [1:0] s_command_dst_code;
  logic             s_ack_src_valid;
  logic             s_ack_src_ready;
  logic             s_ack_dst_valid;
  logic             s_ack_dst_ready;
  logic       [1:0] s_ack_code;
  logic             s_command_fire;
  logic             s_ack_fire;

  initial begin
    if (SYNC_STAGES < 2) begin
      $fatal(1, "cdc_warm_flush_controller: SYNC_STAGES must be at least two");
    end
  end

  // The controller itself has a common reset epoch. A raw reset of either
  // endpoint therefore cannot leave one control FSM waiting for an old command.
  assign s_link_rst_n = src_rst_n_i && dst_rst_n_i;
  cdc_reset_barrier #(
      .STAGES(SYNC_STAGES)
  ) u_control_reset (
      .clk_a_i  (src_clk_i),
      .clk_b_i  (dst_clk_i),
      .rst_n_i  (s_link_rst_n),
      .release_i(1'b1),
      .rst_a_n_o(s_src_ctrl_rst_n),
      .rst_b_n_o(s_dst_ctrl_rst_n)
  );

  // Commands travel source-to-destination, acknowledgements travel back. Both
  // use the existing four-phase mailbox, so each phase is retained until the
  // receiver has observed it despite arbitrary clock ratios.
  async_reqack #(
      .DATA_WIDTH (2),
      .SYNC_STAGES(SYNC_STAGES)
  ) u_command_mailbox (
      .src_clk_i  (src_clk_i),
      .src_rst_n_i(s_src_ctrl_rst_n),
      .src_valid_i(s_command_valid),
      .src_ready_o(s_command_ready),
      .src_data_i (s_command_code),
      .dst_clk_i  (dst_clk_i),
      .dst_rst_n_i(s_dst_ctrl_rst_n),
      .dst_valid_o(s_command_dst_valid),
      .dst_ready_i(s_command_dst_ready),
      .dst_data_o (s_command_dst_code)
  );
  async_reqack #(
      .DATA_WIDTH (2),
      .SYNC_STAGES(SYNC_STAGES)
  ) u_ack_mailbox (
      .src_clk_i  (dst_clk_i),
      .src_rst_n_i(s_dst_ctrl_rst_n),
      .src_valid_i(s_ack_src_valid),
      .src_ready_o(s_ack_src_ready),
      .src_data_i (r_dst_ack_code),
      .dst_clk_i  (src_clk_i),
      .dst_rst_n_i(s_src_ctrl_rst_n),
      .dst_valid_o(s_ack_dst_valid),
      .dst_ready_i(s_ack_dst_ready),
      .dst_data_o (s_ack_code)
  );

  // A command is only consumed if its matching acknowledgement can be queued.
  // This removes any dependency on a fixed ratio between the two clocks.
  assign s_command_dst_ready = !r_dst_ack_pending && s_ack_src_ready;
  assign s_command_fire      = s_command_dst_valid && s_command_dst_ready;
  assign s_ack_src_valid     = r_dst_ack_pending;
  assign s_ack_fire          = s_ack_src_valid && s_ack_src_ready;

  always_comb begin
    s_command_valid = 1'b0;
    s_command_code  = '0;
    s_ack_dst_ready = 1'b0;
    unique case (r_src_state)
      SRC_SEND_ISOLATE: begin
        s_command_valid = 1'b1;
        s_command_code  = CMD_ISOLATE;
      end
      SRC_SEND_RESET: begin
        s_command_valid = 1'b1;
        s_command_code  = CMD_RESET;
      end
      SRC_SEND_RESUME: begin
        s_command_valid = 1'b1;
        s_command_code  = CMD_RESUME;
      end
      SRC_WAIT_ISOLATE, SRC_WAIT_RESET, SRC_WAIT_RESUME: s_ack_dst_ready = 1'b1;
      default: begin
      end
    endcase
  end

  always_ff @(posedge src_clk_i or negedge s_src_ctrl_rst_n) begin
    if (!s_src_ctrl_rst_n) begin
      r_src_state   <= SRC_IDLE;
      r_src_isolate <= 1'b0;
      r_src_reset   <= 1'b0;
    end else begin
      r_src_reset <= 1'b0;
      unique case (r_src_state)
        SRC_IDLE: begin
          if (src_clear_i) begin
            r_src_isolate <= 1'b1;
            r_src_state   <= SRC_SEND_ISOLATE;
          end
        end
        SRC_SEND_ISOLATE: begin
          if (s_command_ready) r_src_state <= SRC_WAIT_ISOLATE;
        end
        SRC_WAIT_ISOLATE: begin
          if (s_ack_dst_valid && s_ack_dst_ready && (s_ack_code == CMD_ISOLATE)) begin
            r_src_state <= SRC_SEND_RESET;
          end
        end
        SRC_SEND_RESET: begin
          if (s_command_ready) begin
            r_src_reset <= 1'b1;
            r_src_state <= SRC_WAIT_RESET;
          end
        end
        SRC_WAIT_RESET: begin
          if (s_ack_dst_valid && s_ack_dst_ready && (s_ack_code == CMD_RESET)) begin
            r_src_state <= SRC_SEND_RESUME;
          end
        end
        SRC_SEND_RESUME: begin
          if (s_command_ready) r_src_state <= SRC_WAIT_RESUME;
        end
        SRC_WAIT_RESUME: begin
          if (s_ack_dst_valid && s_ack_dst_ready && (s_ack_code == CMD_RESUME)) begin
            r_src_isolate <= 1'b0;
            r_src_state   <= SRC_IDLE;
          end
        end
        default: r_src_state <= SRC_IDLE;
      endcase
    end
  end

  always_ff @(posedge dst_clk_i or negedge s_dst_ctrl_rst_n) begin
    if (!s_dst_ctrl_rst_n) begin
      r_dst_isolate     <= 1'b0;
      r_dst_reset       <= 1'b0;
      r_dst_ack_pending <= 1'b0;
      r_dst_ack_code    <= '0;
    end else begin
      r_dst_reset <= 1'b0;
      if (s_ack_fire) r_dst_ack_pending <= 1'b0;
      if (s_command_fire) begin
        r_dst_ack_code    <= s_command_dst_code;
        r_dst_ack_pending <= 1'b1;
        unique case (s_command_dst_code)
          CMD_ISOLATE: r_dst_isolate <= 1'b1;
          CMD_RESET:   r_dst_reset <= 1'b1;
          CMD_RESUME:  r_dst_isolate <= 1'b0;
          default:     r_dst_isolate <= r_dst_isolate;
        endcase
      end
    end
  end

  assign src_isolate_o = r_src_isolate;
  assign src_reset_o   = r_src_reset;
  assign src_busy_o    = (r_src_state != SRC_IDLE);
  assign dst_isolate_o = r_dst_isolate;
  assign dst_reset_o   = r_dst_reset;
  assign dst_busy_o    = r_dst_isolate || r_dst_ack_pending;

`ifndef SYNTHESIS
  always_ff @(posedge src_clk_i) begin
    if (s_src_ctrl_rst_n && src_clear_i && (r_src_state != SRC_IDLE)) begin
      $fatal(1, "cdc_warm_flush_controller: src_clear_i asserted while busy");
    end
    if (s_src_ctrl_rst_n && s_ack_dst_valid && s_ack_dst_ready) begin
      unique case (r_src_state)
        SRC_WAIT_ISOLATE:
        if (s_ack_code != CMD_ISOLATE) $fatal(1, "CDC flush isolate ack mismatch");
        SRC_WAIT_RESET: if (s_ack_code != CMD_RESET) $fatal(1, "CDC flush reset ack mismatch");
        SRC_WAIT_RESUME: if (s_ack_code != CMD_RESUME) $fatal(1, "CDC flush resume ack mismatch");
        default: begin
        end
      endcase
    end
  end
`endif
endmodule

module cdc_2phase_warm_flush #(
    parameter int DATA_WIDTH  = 32,
    parameter int SYNC_STAGES = 2
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
    output logic                  dst_clear_busy_o,
    output logic [DATA_WIDTH-1:0] dst_data_o,
    output logic                  dst_valid_o,
    input  logic                  dst_ready_i
);
  logic s_src_isolate;
  logic s_src_reset;
  logic s_dst_isolate;
  logic s_dst_reset;
  logic s_src_ready;
  logic s_dst_valid;

  cdc_warm_flush_controller #(
      .SYNC_STAGES(SYNC_STAGES)
  ) u_flush_controller (
      .src_clk_i    (src_clk_i),
      .src_rst_n_i  (src_rst_n_i),
      .src_clear_i  (src_clear_i),
      .src_isolate_o(s_src_isolate),
      .src_reset_o  (s_src_reset),
      .src_busy_o   (src_clear_busy_o),
      .dst_clk_i    (dst_clk_i),
      .dst_rst_n_i  (dst_rst_n_i),
      .dst_isolate_o(s_dst_isolate),
      .dst_reset_o  (s_dst_reset),
      .dst_busy_o   (dst_clear_busy_o)
  );
  cdc_2phase #(
      .DATA_WIDTH (DATA_WIDTH),
      .SYNC_STAGES(SYNC_STAGES)
  ) u_payload_cdc (
      .src_clk_i  (src_clk_i),
      .src_rst_n_i(src_rst_n_i && !s_src_reset),
      .src_data_i (src_data_i),
      .src_valid_i(src_valid_i),
      .src_ready_o(s_src_ready),
      .dst_clk_i  (dst_clk_i),
      .dst_rst_n_i(dst_rst_n_i && !s_dst_reset),
      .dst_data_o (dst_data_o),
      .dst_valid_o(s_dst_valid),
      .dst_ready_i(dst_ready_i)
  );

  assign src_ready_o = s_src_ready && !s_src_isolate;
  assign dst_valid_o = s_dst_valid && !s_dst_isolate;
endmodule

module cdc_fifo_warm_flush #(
    parameter int DATA_WIDTH   = 32,
    parameter int BUFFER_DEPTH = 8,
    parameter int SYNC_STAGES  = 2
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
    output logic                  dst_clear_busy_o,
    output logic [DATA_WIDTH-1:0] dst_data_o,
    output logic                  dst_valid_o,
    input  logic                  dst_ready_i
);
  logic s_src_isolate;
  logic s_src_reset;
  logic s_dst_isolate;
  logic s_dst_reset;
  logic s_src_ready;
  logic s_dst_valid;

  cdc_warm_flush_controller #(
      .SYNC_STAGES(SYNC_STAGES)
  ) u_flush_controller (
      .src_clk_i    (src_clk_i),
      .src_rst_n_i  (src_rst_n_i),
      .src_clear_i  (src_clear_i),
      .src_isolate_o(s_src_isolate),
      .src_reset_o  (s_src_reset),
      .src_busy_o   (src_clear_busy_o),
      .dst_clk_i    (dst_clk_i),
      .dst_rst_n_i  (dst_rst_n_i),
      .dst_isolate_o(s_dst_isolate),
      .dst_reset_o  (s_dst_reset),
      .dst_busy_o   (dst_clear_busy_o)
  );
  cdc_fifo #(
      .DATA_WIDTH  (DATA_WIDTH),
      .BUFFER_DEPTH(BUFFER_DEPTH),
      .SYNC_STAGES (SYNC_STAGES)
  ) u_payload_cdc (
      .src_clk_i  (src_clk_i),
      .src_rst_n_i(src_rst_n_i && !s_src_reset),
      .src_data_i (src_data_i),
      .src_valid_i(src_valid_i),
      .src_ready_o(s_src_ready),
      .dst_clk_i  (dst_clk_i),
      .dst_rst_n_i(dst_rst_n_i && !s_dst_reset),
      .dst_data_o (dst_data_o),
      .dst_valid_o(s_dst_valid),
      .dst_ready_i(dst_ready_i)
  );

  assign src_ready_o = s_src_ready && !s_src_isolate;
  assign dst_valid_o = s_dst_valid && !s_dst_isolate;
endmodule
