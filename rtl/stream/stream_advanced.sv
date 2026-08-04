// Copyright 2018-2024 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy at
// http://solderpad.org/licenses/SHL-0.51.
// SPDX-License-Identifier: SHL-0.51
//
// Original concepts include fall-through registers, stream FIFOs, lossy
// valid-only adaptation, delay injection, and stream arbitration.
// Derived design work: Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// Design independently implemented for common; see NOTICE for attribution.

module stream_elastic_register #(
    parameter int DATA_WIDTH = 32
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  flush_i,
    input  logic                  in_valid_i,
    output logic                  in_ready_o,
    input  logic [DATA_WIDTH-1:0] in_data_i,
    output logic                  out_valid_o,
    input  logic                  out_ready_i,
    output logic [DATA_WIDTH-1:0] out_data_o
);
  logic r_valid;
  logic s_load;

  assign in_ready_o  = !flush_i && (out_ready_i || !r_valid);
  assign out_valid_o = r_valid && !flush_i;
  assign s_load      = in_valid_i && in_ready_o;

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      r_valid    <= 1'b0;
      out_data_o <= '0;
    end else if (flush_i) begin
      r_valid    <= 1'b0;
      out_data_o <= '0;
    end else if (in_ready_o) begin
      r_valid <= in_valid_i;
      if (s_load) out_data_o <= in_data_i;
    end
  end

  initial begin
    if (DATA_WIDTH < 1) $fatal(1, "stream_elastic_register: DATA_WIDTH must be positive");
  end
endmodule

// An arbitrary-depth ready/valid queue. The FALL_THROUGH path avoids an
// empty-queue bubble while preserving stable output data under backpressure.
module stream_queue #(
    parameter int DATA_WIDTH   = 32,
    parameter int DEPTH        = 4,
    parameter bit FALL_THROUGH = 1'b1,
    parameter int PTR_WIDTH    = (DEPTH > 1) ? $clog2(DEPTH) : 1,
    parameter int COUNT_WIDTH  = $clog2(DEPTH + 1)
) (
    input  logic                   clk_i,
    input  logic                   rst_n_i,
    input  logic                   flush_i,
    input  logic                   in_valid_i,
    output logic                   in_ready_o,
    input  logic [ DATA_WIDTH-1:0] in_data_i,
    output logic                   out_valid_o,
    input  logic                   out_ready_i,
    output logic [ DATA_WIDTH-1:0] out_data_o,
    output logic [COUNT_WIDTH-1:0] usage_o
);
  logic [ DATA_WIDTH-1:0] r_storage     [0:DEPTH-1];
  logic [  PTR_WIDTH-1:0] r_read_ptr;
  logic [  PTR_WIDTH-1:0] r_write_ptr;
  logic [COUNT_WIDTH-1:0] r_usage;
  logic                   s_empty;
  logic                   s_full;
  logic                   s_bypass;
  logic                   s_output_take;
  logic                   s_input_take;
  logic                   s_store_push;
  logic                   s_store_pop;

  assign s_empty       = (r_usage == '0);
  assign s_full        = (r_usage == COUNT_WIDTH'(DEPTH));
  assign s_bypass      = FALL_THROUGH && s_empty;
  assign out_valid_o   = !flush_i && (s_bypass ? in_valid_i : !s_empty);
  assign out_data_o    = s_bypass ? in_data_i : (s_empty ? '0 : r_storage[r_read_ptr]);
  assign s_output_take = out_valid_o && out_ready_i;
  assign in_ready_o    = !flush_i && (!s_full || s_output_take);
  assign s_input_take  = in_valid_i && in_ready_o;
  assign s_store_push  = s_input_take && !(s_bypass && s_output_take);
  assign s_store_pop   = s_output_take && !s_bypass;
  assign usage_o       = r_usage;

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      r_read_ptr  <= '0;
      r_write_ptr <= '0;
      r_usage     <= '0;
    end else if (flush_i) begin
      r_read_ptr  <= '0;
      r_write_ptr <= '0;
      r_usage     <= '0;
    end else begin
      if (s_store_push) begin
        r_storage[r_write_ptr] <= in_data_i;
        if (r_write_ptr == PTR_WIDTH'(DEPTH - 1)) r_write_ptr <= '0;
        else r_write_ptr <= r_write_ptr + 1'b1;
      end
      if (s_store_pop) begin
        if (r_read_ptr == PTR_WIDTH'(DEPTH - 1)) r_read_ptr <= '0;
        else r_read_ptr <= r_read_ptr + 1'b1;
      end
      unique case ({
        s_store_push, s_store_pop
      })
        2'b10:   r_usage <= r_usage + 1'b1;
        2'b01:   r_usage <= r_usage - 1'b1;
        default: r_usage <= r_usage;
      endcase
    end
  end

  initial begin
    if (DATA_WIDTH < 1 || DEPTH < 2 || PTR_WIDTH < $clog2(
            DEPTH
        ) || COUNT_WIDTH < $clog2(
            DEPTH + 1
        )) begin
      $fatal(1, "stream_queue: invalid queue geometry");
    end
  end
endmodule

module stream_fallthrough_buffer #(
    parameter int DATA_WIDTH = 32
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  flush_i,
    input  logic                  in_valid_i,
    output logic                  in_ready_o,
    input  logic [DATA_WIDTH-1:0] in_data_i,
    output logic                  out_valid_o,
    input  logic                  out_ready_i,
    output logic [DATA_WIDTH-1:0] out_data_o
);
  logic [1:0] s_usage;
  stream_queue #(
      .DATA_WIDTH  (DATA_WIDTH),
      .DEPTH       (2),
      .FALL_THROUGH(1'b1)
  ) u_queue (
      .clk_i,
      .rst_n_i,
      .flush_i,
      .in_valid_i,
      .in_ready_o,
      .in_data_i,
      .out_valid_o,
      .out_ready_i,
      .out_data_o,
      .usage_o(s_usage)
  );
endmodule

// Converts a valid-only producer to ready/valid. The producer is never
// backpressured; when the two-entry retention window is full, the newest
// pending value replaces the older pending value while the current output word
// remains stable until accepted.
module latest_value_stream #(
    parameter int DATA_WIDTH = 32
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  clear_i,
    input  logic                  in_valid_i,
    input  logic [DATA_WIDTH-1:0] in_data_i,
    output logic                  out_valid_o,
    input  logic                  out_ready_i,
    output logic [DATA_WIDTH-1:0] out_data_o,
    output logic                  busy_o
);
  logic [DATA_WIDTH-1:0] r_storage        [0:1];
  logic                  r_read_ptr;
  logic                  r_write_ptr;
  logic [           1:0] r_count;
  logic                  s_output_take;
  logic                  s_store_input;
  logic                  s_overwrite_tail;

  assign out_valid_o      = (r_count != '0) || in_valid_i;
  assign out_data_o       = (r_count == '0) ? in_data_i : r_storage[r_read_ptr];
  assign busy_o           = (r_count != '0);
  assign s_output_take    = out_valid_o && out_ready_i;
  assign s_store_input    = in_valid_i && !((r_count == '0) && out_ready_i);
  assign s_overwrite_tail = (r_count == 2) && !out_ready_i && in_valid_i;

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i || clear_i) begin
      r_read_ptr  <= 1'b0;
      r_write_ptr <= 1'b0;
      r_count     <= '0;
    end else begin
      if (s_overwrite_tail) begin
        r_storage[r_write_ptr-1'b1] <= in_data_i;
      end else if (s_store_input) begin
        r_storage[r_write_ptr] <= in_data_i;
        r_write_ptr            <= r_write_ptr + 1'b1;
      end
      if ((r_count != '0) && s_output_take) r_read_ptr <= r_read_ptr + 1'b1;
      unique case ({
        in_valid_i, s_output_take
      })
        2'b10: begin
          if (!((r_count == '0) && out_ready_i) && (r_count != 2)) r_count <= r_count + 1'b1;
        end
        2'b01: begin
          if (r_count != '0) r_count <= r_count - 1'b1;
        end
        default: r_count <= r_count;
      endcase
    end
  end

  initial begin
    if (DATA_WIDTH < 1) $fatal(1, "latest_value_stream: DATA_WIDTH must be positive");
  end
endmodule

module stream_delay_injector #(
    parameter int          DATA_WIDTH   = 32,
    parameter int          FIXED_DELAY  = 1,
    parameter bit          RANDOM_DELAY = 1'b0,
    parameter logic [15:0] RANDOM_SEED  = 16'h1,
    parameter logic [15:0] RANDOM_POLY  = 16'hB400
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  clear_i,
    input  logic                  in_valid_i,
    output logic                  in_ready_o,
    input  logic [DATA_WIDTH-1:0] in_data_i,
    output logic                  out_valid_o,
    input  logic                  out_ready_i,
    output logic [DATA_WIDTH-1:0] out_data_o
);
  localparam int COUNT_WIDTH = (FIXED_DELAY > 1) ? $clog2(FIXED_DELAY + 1) : 1;
  logic [ DATA_WIDTH-1:0] r_data;
  logic [COUNT_WIDTH-1:0] r_delay;
  logic                   r_pending;
  logic [           15:0] s_random;
  logic [COUNT_WIDTH-1:0] s_selected_delay;

  lfsr_galois #(
      .DATA_WIDTH(16),
      .POLY      (RANDOM_POLY),
      .RESET_SEED(RANDOM_SEED)
  ) u_lfsr (
      .clk_i,
      .rst_n_i,
      .wr_i (in_valid_i && in_ready_o),
      .dat_i('0),
      .dat_o(s_random)
  );

  always_comb begin
    if (RANDOM_DELAY) s_selected_delay = s_random[COUNT_WIDTH-1:0];
    else s_selected_delay = COUNT_WIDTH'(FIXED_DELAY);
  end
  assign in_ready_o  = !r_pending;
  assign out_valid_o = r_pending && (r_delay == '0);
  assign out_data_o  = r_data;

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i || clear_i) begin
      r_pending <= 1'b0;
      r_delay   <= '0;
      r_data    <= '0;
    end else if (!r_pending && in_valid_i) begin
      r_data    <= in_data_i;
      r_delay   <= s_selected_delay;
      r_pending <= 1'b1;
    end else if (r_pending && (r_delay != '0)) begin
      r_delay <= r_delay - 1'b1;
    end else if (out_valid_o && out_ready_i) begin
      r_pending <= 1'b0;
    end
  end

  initial begin
    if (DATA_WIDTH < 1 || FIXED_DELAY < 0 || RANDOM_SEED == '0 || RANDOM_POLY == '0) begin
      $fatal(1, "stream_delay_injector: invalid parameter");
    end
  end
endmodule

module stream_fair_arbiter #(
    parameter int DATA_WIDTH     = 32,
    parameter int PORTS          = 4,
    parameter bit FIXED_PRIORITY = 1'b0,
    parameter int INDEX_WIDTH    = (PORTS > 1) ? $clog2(PORTS) : 1
) (
    input  logic                                   clk_i,
    input  logic                                   rst_n_i,
    input  logic                                   clear_i,
    input  logic [      PORTS-1:0]                 in_valid_i,
    output logic [      PORTS-1:0]                 in_ready_o,
    input  logic [      PORTS-1:0][DATA_WIDTH-1:0] in_data_i,
    output logic                                   out_valid_o,
    input  logic                                   out_ready_i,
    output logic [ DATA_WIDTH-1:0]                 out_data_o,
    output logic [INDEX_WIDTH-1:0]                 selected_o
);
  logic [      PORTS-1:0] s_rr_grant;
  logic [INDEX_WIDTH-1:0] s_rr_selected;
  logic                   s_rr_valid;
  logic [      PORTS-1:0] s_grant;
  logic [INDEX_WIDTH-1:0] s_selected;
  logic                   s_valid;
  logic                   s_advance;
  logic                   r_locked;
  logic [INDEX_WIDTH-1:0] r_selected;
  logic                   s_found;

  round_robin_arbiter #(
      .CLIENTS    (PORTS),
      .INDEX_WIDTH(INDEX_WIDTH)
  ) u_round_robin (
      .clk_i,
      .rst_n_i,
      .advance_i (s_advance && !FIXED_PRIORITY),
      .request_i (in_valid_i),
      .grant_o   (s_rr_grant),
      .selected_o(s_rr_selected),
      .valid_o   (s_rr_valid)
  );

  always_comb begin
    s_grant    = s_rr_grant;
    s_selected = s_rr_selected;
    s_valid    = s_rr_valid;
    s_found    = 1'b0;
    if (FIXED_PRIORITY) begin
      s_grant    = '0;
      s_found    = 1'b0;
      s_selected = '0;
      for (int unsigned port_idx = 0; port_idx < PORTS; port_idx++) begin
        if (!s_found && in_valid_i[port_idx]) begin
          s_grant[port_idx] = 1'b1;
          s_selected        = INDEX_WIDTH'(port_idx);
          s_found           = 1'b1;
        end
      end
      s_valid = s_found;
    end
  end

  // The selected source is held while the downstream stalls, enforcing the
  // normal ready/valid stability rule even if other requesters appear.
  assign selected_o = r_locked ? r_selected : s_selected;
  assign out_valid_o = r_locked ? in_valid_i[r_selected] : s_valid;
  assign out_data_o = r_locked ? in_data_i[r_selected] : in_data_i[s_selected];
  assign in_ready_o  = r_locked ? ({PORTS{out_ready_i}} & ({{(PORTS-1){1'b0}}, 1'b1} << r_selected)) :
      ({PORTS{out_ready_i}} & s_grant);
  assign s_advance = out_valid_o && out_ready_i;

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i || clear_i) begin
      r_locked   <= 1'b0;
      r_selected <= '0;
    end else if (!r_locked && s_valid && !out_ready_i) begin
      r_locked   <= 1'b1;
      r_selected <= s_selected;
    end else if (r_locked && out_ready_i && in_valid_i[r_selected]) begin
      r_locked <= 1'b0;
    end
  end

  initial begin
    if (DATA_WIDTH < 1 || PORTS < 2 || INDEX_WIDTH < $clog2(PORTS)) begin
      $fatal(1, "stream_fair_arbiter: invalid geometry");
    end
  end
endmodule

// A fully connected stream switch. Every input nominates one output; each
// output arbitrates its contenders independently. Arbitration is locked while
// an output stalls, so AXI-style valid/data stability is preserved.
module stream_crossbar #(
    parameter int DATA_WIDTH     = 32,
    parameter int INPUTS         = 4,
    parameter int OUTPUTS        = 4,
    parameter bit FIXED_PRIORITY = 1'b0,
    parameter int TARGET_WIDTH   = (OUTPUTS > 1) ? $clog2(OUTPUTS) : 1,
    parameter int SOURCE_WIDTH   = (INPUTS > 1) ? $clog2(INPUTS) : 1
) (
    input  logic                                 clk_i,
    input  logic                                 rst_n_i,
    input  logic                                 clear_i,
    input  logic [ INPUTS-1:0]                   in_valid_i,
    output logic [ INPUTS-1:0]                   in_ready_o,
    input  logic [ INPUTS-1:0][  DATA_WIDTH-1:0] in_data_i,
    input  logic [ INPUTS-1:0][TARGET_WIDTH-1:0] target_i,
    output logic [OUTPUTS-1:0]                   out_valid_o,
    input  logic [OUTPUTS-1:0]                   out_ready_i,
    output logic [OUTPUTS-1:0][  DATA_WIDTH-1:0] out_data_o,
    output logic [OUTPUTS-1:0][SOURCE_WIDTH-1:0] source_o
);
  logic [      INPUTS-1:0] s_request[0:OUTPUTS-1];
  logic [      INPUTS-1:0] s_ready  [0:OUTPUTS-1];
  logic [SOURCE_WIDTH-1:0] s_source [0:OUTPUTS-1];

  for (genvar output_idx = 0; output_idx < OUTPUTS; output_idx++) begin : GEN_OUTPUT
    for (genvar input_idx = 0; input_idx < INPUTS; input_idx++) begin : GEN_REQUEST
      assign s_request[output_idx][input_idx] = in_valid_i[input_idx] &&
          (target_i[input_idx] == TARGET_WIDTH'(output_idx));
    end
    stream_fair_arbiter #(
        .DATA_WIDTH    (DATA_WIDTH),
        .PORTS         (INPUTS),
        .FIXED_PRIORITY(FIXED_PRIORITY),
        .INDEX_WIDTH   (SOURCE_WIDTH)
    ) u_arbiter (
        .clk_i,
        .rst_n_i,
        .clear_i,
        .in_valid_i (s_request[output_idx]),
        .in_ready_o (s_ready[output_idx]),
        .in_data_i  (in_data_i),
        .out_valid_o(out_valid_o[output_idx]),
        .out_ready_i(out_ready_i[output_idx]),
        .out_data_o (out_data_o[output_idx]),
        .selected_o (s_source[output_idx])
    );
    assign source_o[output_idx] = s_source[output_idx];
  end

  always_comb begin
    in_ready_o = '0;
    for (int unsigned input_idx = 0; input_idx < INPUTS; input_idx++) begin
      for (int unsigned output_idx = 0; output_idx < OUTPUTS; output_idx++) begin
        if (target_i[input_idx] == TARGET_WIDTH'(output_idx)) begin
          in_ready_o[input_idx] = s_ready[output_idx][input_idx];
        end
      end
    end
  end

  initial begin
    if (DATA_WIDTH < 1 || INPUTS < 2 || OUTPUTS < 1 || TARGET_WIDTH < ((OUTPUTS > 1) ? $clog2(
            OUTPUTS
        ) : 1) || SOURCE_WIDTH < ((INPUTS > 1) ? $clog2(
            INPUTS
        ) : 1)) begin
      $fatal(1, "stream_crossbar: invalid geometry");
    end
  end
endmodule

// A resource-constrained network API for topology-sensitive users. The
// implementation intentionally delegates arbitration and locking to the
// verified crossbar primitive; synthesis may optimize unused routes.
module stream_shuffle_network #(
    parameter int DATA_WIDTH   = 32,
    parameter int INPUTS       = 4,
    parameter int OUTPUTS      = 4,
    parameter int TARGET_WIDTH = (OUTPUTS > 1) ? $clog2(OUTPUTS) : 1,
    parameter int SOURCE_WIDTH = (INPUTS > 1) ? $clog2(INPUTS) : 1
) (
    input  logic                                 clk_i,
    input  logic                                 rst_n_i,
    input  logic                                 clear_i,
    input  logic [ INPUTS-1:0]                   in_valid_i,
    output logic [ INPUTS-1:0]                   in_ready_o,
    input  logic [ INPUTS-1:0][  DATA_WIDTH-1:0] in_data_i,
    input  logic [ INPUTS-1:0][TARGET_WIDTH-1:0] target_i,
    output logic [OUTPUTS-1:0]                   out_valid_o,
    input  logic [OUTPUTS-1:0]                   out_ready_i,
    output logic [OUTPUTS-1:0][  DATA_WIDTH-1:0] out_data_o,
    output logic [OUTPUTS-1:0][SOURCE_WIDTH-1:0] source_o
);
  stream_crossbar #(
      .DATA_WIDTH    (DATA_WIDTH),
      .INPUTS        (INPUTS),
      .OUTPUTS       (OUTPUTS),
      .FIXED_PRIORITY(1'b0),
      .TARGET_WIDTH  (TARGET_WIDTH),
      .SOURCE_WIDTH  (SOURCE_WIDTH)
  ) u_crossbar (
      .clk_i,
      .rst_n_i,
      .clear_i,
      .in_valid_i,
      .in_ready_o,
      .in_data_i,
      .target_i,
      .out_valid_o,
      .out_ready_i,
      .out_data_o,
      .source_o
  );
endmodule

// Bridges a request stream to an unbackpressured memory response channel. A
// response queue bounds outstanding operations; depth zero is intentionally
// not supported because it requires a same-cycle memory response contract.
module memory_response_bridge #(
    parameter int REQUEST_WIDTH  = 32,
    parameter int RESPONSE_WIDTH = 32,
    parameter int RESPONSE_DEPTH = 2,
    parameter int COUNT_WIDTH    = $clog2(RESPONSE_DEPTH + 1)
) (
    input  logic                      clk_i,
    input  logic                      rst_n_i,
    input  logic                      clear_i,
    input  logic [ REQUEST_WIDTH-1:0] request_i,
    input  logic                      request_valid_i,
    output logic                      request_ready_o,
    output logic [ REQUEST_WIDTH-1:0] memory_request_o,
    output logic                      memory_request_valid_o,
    input  logic                      memory_request_ready_i,
    input  logic [RESPONSE_WIDTH-1:0] memory_response_i,
    input  logic                      memory_response_valid_i,
    output logic [RESPONSE_WIDTH-1:0] response_o,
    output logic                      response_valid_o,
    input  logic                      response_ready_i
);
  logic [COUNT_WIDTH-1:0] r_outstanding;
  logic [COUNT_WIDTH-1:0] s_usage;
  logic                   s_response_ready;
  logic                   s_request_fire;
  logic                   s_response_fire;
  logic                   s_capacity;

  stream_queue #(
      .DATA_WIDTH  (RESPONSE_WIDTH),
      .DEPTH       (RESPONSE_DEPTH),
      .FALL_THROUGH(1'b1)
  ) u_response_queue (
      .clk_i,
      .rst_n_i,
      .flush_i    (clear_i),
      .in_valid_i (memory_response_valid_i),
      .in_ready_o (s_response_ready),
      .in_data_i  (memory_response_i),
      .out_valid_o(response_valid_o),
      .out_ready_i(response_ready_i),
      .out_data_o (response_o),
      .usage_o    (s_usage)
  );

  assign s_capacity = (r_outstanding < COUNT_WIDTH'(RESPONSE_DEPTH)) ||
      (response_valid_o && response_ready_i);
  assign memory_request_o = request_i;
  assign memory_request_valid_o = request_valid_i && s_capacity && !clear_i;
  assign request_ready_o = memory_request_ready_i && s_capacity && !clear_i;
  assign s_request_fire = memory_request_valid_o && memory_request_ready_i;
  assign s_response_fire = response_valid_o && response_ready_i;

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i || clear_i) begin
      r_outstanding <= '0;
    end else begin
      unique case ({
        s_request_fire, s_response_fire
      })
        2'b10:   r_outstanding <= r_outstanding + 1'b1;
        2'b01:   r_outstanding <= r_outstanding - 1'b1;
        default: r_outstanding <= r_outstanding;
      endcase
    end
  end

`ifndef SYNTHESIS
  always_ff @(posedge clk_i) begin
    if (rst_n_i && !clear_i && memory_response_valid_i && !s_response_ready) begin
      $fatal(1, "memory_response_bridge: memory response queue overflow");
    end
  end
`endif

  initial begin
    if (REQUEST_WIDTH < 1 || RESPONSE_WIDTH < 1 || RESPONSE_DEPTH < 2 || COUNT_WIDTH < $clog2(
            RESPONSE_DEPTH + 1
        )) begin
      $fatal(1, "memory_response_bridge: invalid geometry");
    end
  end
endmodule
