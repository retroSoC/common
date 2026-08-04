// Copyright 2019-2026 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy at
// http://solderpad.org/licenses/SHL-0.51.
// SPDX-License-Identifier: SHL-0.51
//
// Original concepts include credit accounting, exponential backoff, trip
// counters, serial deglitching, and majority filtering.
// Derived design work: Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// Design independently implemented for common; see NOTICE for attribution.

module credit_pool #(
    parameter int MAX_CREDITS    = 4,
    parameter bit EMPTY_ON_RESET = 1'b0,
    parameter int COUNT_WIDTH    = $clog2(MAX_CREDITS + 1)
) (
    input  logic                   clk_i,
    input  logic                   rst_n_i,
    input  logic                   clear_i,
    input  logic                   give_i,
    input  logic                   take_i,
    output logic [COUNT_WIDTH-1:0] available_o,
    output logic                   has_credit_o,
    output logic                   one_from_full_o,
    output logic                   full_o
);
  logic [COUNT_WIDTH-1:0] r_credit;

  assign available_o     = r_credit;
  assign has_credit_o    = (r_credit != '0);
  assign one_from_full_o = (r_credit == COUNT_WIDTH'(MAX_CREDITS - 1));
  assign full_o          = (r_credit == COUNT_WIDTH'(MAX_CREDITS));

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i || clear_i) begin
      r_credit <= EMPTY_ON_RESET ? '0 : COUNT_WIDTH'(MAX_CREDITS);
    end else begin
      unique case ({
        give_i && !take_i, take_i && !give_i
      })
        2'b10: begin
          if (!full_o) r_credit <= r_credit + 1'b1;
        end
        2'b01: begin
          if (has_credit_o) r_credit <= r_credit - 1'b1;
        end
        default: r_credit <= r_credit;
      endcase
    end
  end

`ifndef SYNTHESIS
  always_ff @(posedge clk_i) begin
    if (rst_n_i && !clear_i && take_i && !give_i && !has_credit_o) begin
      $fatal(1, "credit_pool: credit underflow");
    end
    if (rst_n_i && !clear_i && give_i && !take_i && full_o) begin
      $fatal(1, "credit_pool: credit overflow");
    end
  end
`endif

  initial begin
    if (MAX_CREDITS < 1 || COUNT_WIDTH < $clog2(MAX_CREDITS + 1)) begin
      $fatal(1, "credit_pool: invalid credit geometry");
    end
  end
endmodule

// A bounded induction counter. advance_i on the bound emits wrap_o and makes
// the next state zero; callers must select STEP_WIDTH and limit_i such that
// every loop iteration lands exactly on the limit.
module loop_trip_counter #(
    parameter int DATA_WIDTH = 4
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  clear_i,
    input  logic                  advance_i,
    input  logic [DATA_WIDTH-1:0] step_i,
    input  logic [DATA_WIDTH-1:0] limit_i,
    output logic [DATA_WIDTH-1:0] value_o,
    output logic                  at_limit_o,
    output logic                  wrap_o
);
  logic [DATA_WIDTH-1:0] r_value;
  logic [  DATA_WIDTH:0] s_next_value;

  assign value_o    = r_value;
  assign at_limit_o = (r_value == limit_i);
  assign wrap_o     = advance_i && at_limit_o;

  always_comb begin
    s_next_value = {1'b0, r_value};
    if (advance_i && !at_limit_o) s_next_value = {1'b0, r_value} + step_i;
  end

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i || clear_i || wrap_o) begin
      r_value <= '0;
    end else if (advance_i) begin
      r_value <= s_next_value[DATA_WIDTH-1:0];
    end
  end

`ifndef SYNTHESIS
  always_ff @(posedge clk_i) begin
    if (rst_n_i && !clear_i && advance_i && !at_limit_o && (s_next_value > {1'b0, limit_i})) begin
      $fatal(1, "loop_trip_counter: step overshoots limit");
    end
  end
`endif

  initial begin
    if (DATA_WIDTH < 1) $fatal(1, "loop_trip_counter: DATA_WIDTH must be positive");
  end
endmodule

module stable_level_filter #(
    parameter int STABLE_CYCLES = 4,
    parameter int COUNT_WIDTH   = (STABLE_CYCLES > 1) ? $clog2(STABLE_CYCLES) : 1
) (
    input  logic clk_i,
    input  logic rst_n_i,
    input  logic clear_i,
    input  logic restart_i,
    input  logic enable_i,
    input  logic sample_i,
    output logic level_o
);
  logic [COUNT_WIDTH-1:0] r_count;
  logic                   s_different;
  logic                   s_accept_level;

  assign s_different = (sample_i != level_o);
  assign s_accept_level = enable_i && s_different &&
      ((STABLE_CYCLES == 1) || (r_count == COUNT_WIDTH'(STABLE_CYCLES - 1)));

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i || clear_i) begin
      level_o <= 1'b0;
      r_count <= '0;
    end else if (restart_i) begin
      level_o <= sample_i;
      r_count <= '0;
    end else if (!enable_i || !s_different) begin
      r_count <= '0;
    end else if (s_accept_level) begin
      level_o <= sample_i;
      r_count <= '0;
    end else begin
      r_count <= r_count + 1'b1;
    end
  end

  initial begin
    if (STABLE_CYCLES < 1) $fatal(1, "stable_level_filter: STABLE_CYCLES must be positive");
  end
endmodule

module sample_majority_filter #(
    parameter int WINDOW_LENGTH    = 4,
    parameter int ASSERT_THRESHOLD = (WINDOW_LENGTH / 2) + 1,
    parameter int COUNT_WIDTH      = $clog2(WINDOW_LENGTH + 1)
) (
    input  logic clk_i,
    input  logic rst_n_i,
    input  logic clear_i,
    input  logic enable_i,
    input  logic sample_i,
    output logic level_o
);
  logic [WINDOW_LENGTH-1:0] r_history;
  logic [  COUNT_WIDTH-1:0] s_ones;

  bit_count #(
      .WIDTH      (WINDOW_LENGTH),
      .COUNT_WIDTH(COUNT_WIDTH)
  ) u_bit_count (
      .value_i(r_history),
      .count_o(s_ones)
  );

  assign level_o = (s_ones >= COUNT_WIDTH'(ASSERT_THRESHOLD));

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i || clear_i) begin
      r_history <= '0;
    end else if (enable_i) begin
      // A shift expression also elaborates for a one-sample window. The
      // parameter check below still rejects that unsupported configuration.
      r_history <= (r_history << 1) | WINDOW_LENGTH'(sample_i);
    end
  end

  initial begin
    if (WINDOW_LENGTH < 2 || ASSERT_THRESHOLD < 1 || ASSERT_THRESHOLD > WINDOW_LENGTH) begin
      $fatal(1, "sample_majority_filter: invalid window or threshold");
    end
  end
endmodule

module retry_backoff #(
    parameter int                    DATA_WIDTH   = 16,
    parameter int                    MAX_EXPONENT = DATA_WIDTH,
    parameter logic [DATA_WIDTH-1:0] POLYNOMIAL   = 16'hB400,
    parameter logic [DATA_WIDTH-1:0] SEED         = {{(DATA_WIDTH - 1) {1'b0}}, 1'b1}
) (
    input  logic clk_i,
    input  logic rst_n_i,
    input  logic clear_i,
    input  logic failure_i,
    input  logic success_i,
    output logic ready_o
);
  localparam int EXPONENT_INDEX = (MAX_EXPONENT > 0) ? MAX_EXPONENT - 1 : 0;

  logic [DATA_WIDTH-1:0] s_random;
  logic [DATA_WIDTH-1:0] r_mask;
  logic [DATA_WIDTH-1:0] r_wait;

  lfsr_galois #(
      .DATA_WIDTH(DATA_WIDTH),
      .POLY      (POLYNOMIAL),
      .RESET_SEED(SEED)
  ) u_random_source (
      .clk_i  (clk_i),
      .rst_n_i(rst_n_i),
      .wr_i   (failure_i),
      .dat_i  ('0),
      .dat_o  (s_random)
  );

  assign ready_o = (r_wait == '0);

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i || clear_i || success_i) begin
      r_mask <= '0;
      r_wait <= '0;
    end else if (failure_i) begin
      r_wait <= s_random & r_mask;
      if (!r_mask[EXPONENT_INDEX]) begin
        r_mask <= (r_mask << 1) | 1'b1;
      end
    end else if (!ready_o) begin
      r_wait <= r_wait - 1'b1;
    end
  end

  initial begin
    if (DATA_WIDTH < 2 || MAX_EXPONENT < 1 || MAX_EXPONENT > DATA_WIDTH || POLYNOMIAL == '0 ||
        SEED == '0) begin
      $fatal(1, "retry_backoff: invalid LFSR or exponent geometry");
    end
  end
endmodule
