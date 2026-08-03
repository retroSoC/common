// Copyright 2018-2024 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51. You may obtain a copy at
// http://solderpad.org/licenses/SHL-0.51.
//
// Original concepts include stream filtering and outstanding-request limiting.
// Derived design work: Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: SHL-0.51
// Design independently implemented for common; see NOTICE for attribution.

// Drops each input transfer while discard_i is high. The gate is deliberately
// combinational: a source that sees ready has transferred its item, even though
// no downstream transfer occurs.
module stream_discard_gate (
    input  logic in_valid_i,
    output logic in_ready_o,
    input  logic discard_i,
    output logic out_valid_o,
    input  logic out_ready_i
);
  assign out_valid_o = in_valid_i && !discard_i;
  assign in_ready_o  = discard_i || out_ready_i;
endmodule

// Limits the number of accepted requests that have not yet produced retire_i.
// retire_i denotes one completion for a previously accepted request; response
// data remains outside this control-only component.
module stream_window_guard #(
    parameter int MAX_INFLIGHT = 4,
    parameter int COUNT_WIDTH  = $clog2(MAX_INFLIGHT + 1)
) (
    input  logic                   clk_i,
    input  logic                   rst_n_i,
    input  logic                   flush_i,
    input  logic [COUNT_WIDTH-1:0] limit_i,
    input  logic                   submit_valid_i,
    output logic                   submit_ready_o,
    output logic                   forward_valid_o,
    input  logic                   forward_ready_i,
    input  logic                   retire_i,
    output logic [COUNT_WIDTH-1:0] used_o
);
  logic [COUNT_WIDTH-1:0] r_used;
  logic [COUNT_WIDTH-1:0] s_limit;
  logic                   s_retire;
  logic                   s_allow_submit;
  logic                   s_submit;

  initial begin
    if (MAX_INFLIGHT < 1 || COUNT_WIDTH < $clog2(MAX_INFLIGHT + 1)) begin
      $fatal(1, "stream_window_guard: invalid maximum or counter width");
    end
  end

  always_comb begin
    if (limit_i > COUNT_WIDTH'(MAX_INFLIGHT)) begin
      s_limit = COUNT_WIDTH'(MAX_INFLIGHT);
    end else begin
      s_limit = limit_i;
    end
  end

  // A completion in this cycle can make one request slot immediately usable.
  // A completion is only legal for an item that was outstanding before the
  // edge; zero-latency request/response loops must register the completion.
  assign s_retire        = retire_i && (r_used != '0);
  assign s_allow_submit  = (r_used < s_limit) || s_retire;
  assign forward_valid_o = submit_valid_i && s_allow_submit && !flush_i;
  assign submit_ready_o  = forward_ready_i && s_allow_submit && !flush_i;
  assign s_submit        = forward_valid_o && forward_ready_i;
  assign used_o          = r_used;

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      r_used <= '0;
    end else if (flush_i) begin
      r_used <= '0;
    end else begin
      unique case ({
        s_submit, s_retire
      })
        2'b10:   r_used <= r_used + 1'b1;
        2'b01:   r_used <= r_used - 1'b1;
        default: r_used <= r_used;
      endcase
    end
  end

`ifndef SYNTHESIS
  always_ff @(posedge clk_i) begin
    if (rst_n_i && !flush_i && retire_i && (r_used == '0)) begin
      $fatal(1, "stream_window_guard: retire_i without an outstanding request");
    end
    if (rst_n_i && !flush_i && s_submit && (r_used == COUNT_WIDTH'(MAX_INFLIGHT)) &&
        !s_retire) begin
      $fatal(1, "stream_window_guard: outstanding count overflow");
    end
  end
`endif
endmodule
