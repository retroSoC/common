// Copyright 2018-2025 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy at
// http://solderpad.org/licenses/SHL-0.51.
// SPDX-License-Identifier: SHL-0.51
//
// Original concepts include ID-preserving queues, ring buffers, and banked
// memory adapters. Derived design work: Copyright (c) 2026 Yuchi Miao
// <miaoyuchi@ict.ac.cn>. Design independently implemented for common; see
// NOTICE for attribution.

// Stores values in a separate FIFO order for each tag. Allocation is shared
// across tags; the read port selects a tag and may inspect or consume its head.
module tag_order_queue #(
    parameter int DATA_WIDTH        = 32,
    parameter int TAG_WIDTH         = 2,
    parameter int CAPACITY          = 8,
    parameter int COMPARE_PORTS     = 1,
    parameter bit REUSE_POPPED_SLOT = 1'b1,
    parameter int NODE_WIDTH        = (CAPACITY > 1) ? $clog2(CAPACITY) : 1
) (
    input  logic                                     clk_i,
    input  logic                                     rst_n_i,
    input  logic                                     clear_i,
    input  logic                                     write_valid_i,
    output logic                                     write_ready_o,
    input  logic [    TAG_WIDTH-1:0]                 write_tag_i,
    input  logic [   DATA_WIDTH-1:0]                 write_data_i,
    input  logic                                     read_request_i,
    input  logic [    TAG_WIDTH-1:0]                 read_tag_i,
    input  logic                                     read_take_i,
    output logic                                     read_ready_o,
    output logic                                     read_found_o,
    output logic [   DATA_WIDTH-1:0]                 read_data_o,
    input  logic [COMPARE_PORTS-1:0][DATA_WIDTH-1:0] compare_data_i,
    input  logic [COMPARE_PORTS-1:0][DATA_WIDTH-1:0] compare_mask_i,
    input  logic [COMPARE_PORTS-1:0]                 compare_valid_i,
    output logic [COMPARE_PORTS-1:0]                 compare_found_o,
    output logic                                     full_o,
    output logic                                     empty_o
);
  localparam int TAGS = 1 << TAG_WIDTH;
  logic [DATA_WIDTH-1:0] r_data          [0:CAPACITY-1];
  logic [NODE_WIDTH-1:0] r_next          [0:CAPACITY-1];
  logic                  r_free          [0:CAPACITY-1];
  logic [NODE_WIDTH-1:0] r_head          [    0:TAGS-1];
  logic [NODE_WIDTH-1:0] r_tail          [    0:TAGS-1];
  logic                  r_tag_active    [    0:TAGS-1];
  logic                  s_free_found;
  logic [NODE_WIDTH-1:0] s_free_node;
  logic                  s_pop_fire;
  logic                  s_pop_last;
  logic                  s_push_fire;
  logic [NODE_WIDTH-1:0] s_alloc_node;
  logic                  s_push_existing;

  always_comb begin
    s_free_found = 1'b0;
    s_free_node  = '0;
    for (int unsigned node_idx = 0; node_idx < CAPACITY; node_idx++) begin
      if (!s_free_found && r_free[node_idx]) begin
        s_free_found = 1'b1;
        s_free_node  = NODE_WIDTH'(node_idx);
      end
    end
  end

  assign full_o = !s_free_found;
  always_comb begin
    empty_o = 1'b1;
    for (int unsigned node_idx = 0; node_idx < CAPACITY; node_idx++) begin
      if (!r_free[node_idx]) empty_o = 1'b0;
    end
  end
  assign read_ready_o = 1'b1;
  assign read_found_o = read_request_i && r_tag_active[read_tag_i];
  assign read_data_o = read_found_o ? r_data[r_head[read_tag_i]] : '0;
  assign s_pop_fire = read_found_o && read_take_i;
  assign s_pop_last = s_pop_fire && (r_head[read_tag_i] == r_tail[read_tag_i]);
  assign write_ready_o = s_free_found || (REUSE_POPPED_SLOT && s_pop_fire);
  assign s_push_fire = write_valid_i && write_ready_o;
  assign s_alloc_node = s_free_found ? s_free_node : r_head[read_tag_i];
  assign s_push_existing = r_tag_active[write_tag_i] &&
      !(s_pop_last && (write_tag_i == read_tag_i));

  always_comb begin
    compare_found_o = '0;
    for (int unsigned port_idx = 0; port_idx < COMPARE_PORTS; port_idx++) begin
      for (int unsigned node_idx = 0; node_idx < CAPACITY; node_idx++) begin
        if (compare_valid_i[port_idx] && !r_free[node_idx] &&
            ((r_data[node_idx] & compare_mask_i[port_idx]) ==
             (compare_data_i[port_idx] & compare_mask_i[port_idx]))) begin
          compare_found_o[port_idx] = 1'b1;
        end
      end
    end
  end

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i || clear_i) begin
      for (int unsigned node_idx = 0; node_idx < CAPACITY; node_idx++) begin
        r_data[node_idx] <= '0;
        r_next[node_idx] <= '0;
        r_free[node_idx] <= 1'b1;
      end
      for (int unsigned tag_idx = 0; tag_idx < TAGS; tag_idx++) begin
        r_head[tag_idx]       <= '0;
        r_tail[tag_idx]       <= '0;
        r_tag_active[tag_idx] <= 1'b0;
      end
    end else begin
      if (s_pop_fire) begin
        r_free[r_head[read_tag_i]] <= 1'b1;
        if (s_pop_last) begin
          r_tag_active[read_tag_i] <= 1'b0;
        end else begin
          r_head[read_tag_i] <= r_next[r_head[read_tag_i]];
        end
      end
      if (s_push_fire) begin
        r_data[s_alloc_node] <= write_data_i;
        r_next[s_alloc_node] <= '0;
        r_free[s_alloc_node] <= 1'b0;
        if (s_push_existing) begin
          r_next[r_tail[write_tag_i]] <= s_alloc_node;
          r_tail[write_tag_i]         <= s_alloc_node;
        end else begin
          r_head[write_tag_i]       <= s_alloc_node;
          r_tail[write_tag_i]       <= s_alloc_node;
          r_tag_active[write_tag_i] <= 1'b1;
        end
      end
    end
  end

  initial begin
    if (DATA_WIDTH < 1 || TAG_WIDTH < 1 || CAPACITY < 1 || COMPARE_PORTS < 1) begin
      $fatal(1, "tag_order_queue: invalid geometry");
    end
  end
endmodule

// A circular store with sequential writes, restricted random reads, and an
// independently advanced retirement pointer. DEPTH is a power of two.
module circular_store #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 8,
    parameter int ADDR_WIDTH = (DEPTH > 1) ? $clog2(DEPTH) : 1,
    parameter int STEP_WIDTH = $clog2(DEPTH + 1)
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  clear_i,
    input  logic                  write_valid_i,
    output logic                  write_ready_o,
    input  logic [DATA_WIDTH-1:0] write_data_i,
    input  logic                  read_valid_i,
    output logic                  read_ready_o,
    input  logic [ADDR_WIDTH-1:0] read_addr_i,
    output logic [DATA_WIDTH-1:0] read_data_o,
    input  logic                  retire_i,
    input  logic [STEP_WIDTH-1:0] retire_count_i,
    output logic [ADDR_WIDTH-1:0] write_ptr_o,
    output logic [ADDR_WIDTH-1:0] read_ptr_o,
    output logic                  full_o,
    output logic                  empty_o
);
  logic [DATA_WIDTH-1:0] r_storage   [0:DEPTH-1];
  logic [  ADDR_WIDTH:0] r_read_ptr;
  logic [  ADDR_WIDTH:0] r_write_ptr;
  logic [  ADDR_WIDTH:0] s_occupancy;
  logic                  s_in_range;

  assign s_occupancy   = r_write_ptr - r_read_ptr;
  assign empty_o       = (s_occupancy == '0);
  assign full_o        = (s_occupancy == (ADDR_WIDTH + 1)'(DEPTH));
  assign write_ready_o = !full_o;
  assign write_ptr_o   = r_write_ptr[ADDR_WIDTH-1:0];
  assign read_ptr_o    = r_read_ptr[ADDR_WIDTH-1:0];
  assign s_in_range    = (read_addr_i - r_read_ptr[ADDR_WIDTH-1:0]) < s_occupancy;
  assign read_ready_o  = read_valid_i && s_in_range;
  assign read_data_o   = s_in_range ? r_storage[read_addr_i] : '0;

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i || clear_i) begin
      r_read_ptr  <= '0;
      r_write_ptr <= '0;
    end else begin
      if (write_valid_i && write_ready_o) begin
        r_storage[r_write_ptr[ADDR_WIDTH-1:0]] <= write_data_i;
        r_write_ptr                            <= r_write_ptr + 1'b1;
      end
      if (retire_i) r_read_ptr <= r_read_ptr + retire_count_i;
    end
  end

`ifndef SYNTHESIS
  always_ff @(posedge clk_i) begin
    if (rst_n_i && !clear_i && retire_i && (retire_count_i > s_occupancy)) begin
      $fatal(1, "circular_store: retirement overtakes write pointer");
    end
  end
`endif

  initial begin
    if (DATA_WIDTH < 1 || DEPTH < 2 || (DEPTH & (DEPTH - 1)) != 0 || ADDR_WIDTH < $clog2(
            DEPTH
        ) || STEP_WIDTH < $clog2(
            DEPTH + 1
        )) begin
      $fatal(1, "circular_store: invalid geometry");
    end
  end
endmodule

// Splits a full-width request into independently ready byte-contiguous bank
// requests. It permits one outstanding operation and gathers one response from
// every bank before making the combined response visible.
module memory_bank_adapter_detail #(
    parameter int ADDR_WIDTH       = 32,
    parameter int DATA_WIDTH       = 32,
    parameter int WRITE_USER_WIDTH = 1,
    parameter int READ_USER_WIDTH  = 1,
    parameter int BANKS            = 2,
    parameter int BANK_DATA_WIDTH  = DATA_WIDTH / BANKS,
    parameter int BANK_BYTES       = BANK_DATA_WIDTH / 8
) (
    input  logic                                              clk_i,
    input  logic                                              rst_n_i,
    input  logic                                              clear_i,
    input  logic                                              request_valid_i,
    output logic                                              request_ready_o,
    input  logic [      ADDR_WIDTH-1:0]                       request_addr_i,
    input  logic [      DATA_WIDTH-1:0]                       request_write_data_i,
    input  logic [    DATA_WIDTH/8-1:0]                       request_strobe_i,
    input  logic [WRITE_USER_WIDTH-1:0]                       request_user_i,
    input  logic                                              request_write_i,
    output logic                                              response_valid_o,
    input  logic                                              response_ready_i,
    output logic [      DATA_WIDTH-1:0]                       response_data_o,
    output logic [           BANKS-1:0][ READ_USER_WIDTH-1:0] response_user_o,
    output logic [           BANKS-1:0]                       bank_request_valid_o,
    input  logic [           BANKS-1:0]                       bank_request_ready_i,
    output logic [           BANKS-1:0][      ADDR_WIDTH-1:0] bank_addr_o,
    output logic [           BANKS-1:0][ BANK_DATA_WIDTH-1:0] bank_write_data_o,
    output logic [           BANKS-1:0][      BANK_BYTES-1:0] bank_strobe_o,
    output logic [           BANKS-1:0][WRITE_USER_WIDTH-1:0] bank_write_user_o,
    output logic [           BANKS-1:0]                       bank_write_o,
    input  logic [           BANKS-1:0]                       bank_response_valid_i,
    output logic [           BANKS-1:0]                       bank_response_ready_o,
    input  logic [           BANKS-1:0][ BANK_DATA_WIDTH-1:0] bank_response_data_i,
    input  logic [           BANKS-1:0][ READ_USER_WIDTH-1:0] bank_response_user_i
);
  logic                                  r_wait_response;
  logic [BANKS-1:0]                      r_response_seen;
  logic [BANKS-1:0][BANK_DATA_WIDTH-1:0] r_response_data;
  logic [BANKS-1:0][READ_USER_WIDTH-1:0] r_response_user;
  logic                                  s_request_fire;
  logic                                  s_all_response;

  assign request_ready_o      = !r_wait_response && !clear_i && (&bank_request_ready_i);
  assign s_request_fire       = request_valid_i && request_ready_o;
  assign bank_request_valid_o = {BANKS{s_request_fire}};
  for (genvar bank_idx = 0; bank_idx < BANKS; bank_idx++) begin : GEN_BANK_REQUEST
    assign bank_addr_o[bank_idx] = request_addr_i + ADDR_WIDTH'(bank_idx * BANK_BYTES);
    assign bank_write_data_o[bank_idx] = request_write_data_i[bank_idx*BANK_DATA_WIDTH+:BANK_DATA_WIDTH];
    assign bank_strobe_o[bank_idx] = request_strobe_i[bank_idx*BANK_BYTES+:BANK_BYTES];
    assign bank_write_user_o[bank_idx] = request_user_i;
    assign bank_write_o[bank_idx] = request_write_i;
  end
  assign s_all_response        = &r_response_seen;
  assign response_valid_o      = r_wait_response && s_all_response;
  assign response_data_o       = r_response_data;
  assign response_user_o       = r_response_user;
  assign bank_response_ready_o = {BANKS{r_wait_response && !s_all_response}} & ~r_response_seen;

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i || clear_i) begin
      r_wait_response <= 1'b0;
      r_response_seen <= '0;
      r_response_data <= '0;
      r_response_user <= '0;
    end else begin
      if (s_request_fire) begin
        r_wait_response <= 1'b1;
        r_response_seen <= '0;
      end
      for (int unsigned bank_idx = 0; bank_idx < BANKS; bank_idx++) begin
        if (bank_response_valid_i[bank_idx] && bank_response_ready_o[bank_idx]) begin
          r_response_seen[bank_idx] <= 1'b1;
          r_response_data[bank_idx] <= bank_response_data_i[bank_idx];
          r_response_user[bank_idx] <= bank_response_user_i[bank_idx];
        end
      end
      if (response_valid_o && response_ready_i) begin
        r_wait_response <= 1'b0;
        r_response_seen <= '0;
      end
    end
  end

  initial begin
    if (ADDR_WIDTH < 1 || DATA_WIDTH < 8 || DATA_WIDTH % BANKS != 0 || BANKS < 1 ||
        BANK_DATA_WIDTH < 8 || BANK_DATA_WIDTH % 8 != 0 || WRITE_USER_WIDTH < 1 ||
        READ_USER_WIDTH < 1) begin
      $fatal(1, "memory_bank_adapter_detail: invalid geometry");
    end
  end
endmodule

module memory_bank_adapter #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int BANKS      = 2
) (
    input  logic                                              clk_i,
    input  logic                                              rst_n_i,
    input  logic                                              clear_i,
    input  logic                                              request_valid_i,
    output logic                                              request_ready_o,
    input  logic [  ADDR_WIDTH-1:0]                           request_addr_i,
    input  logic [  DATA_WIDTH-1:0]                           request_write_data_i,
    input  logic [DATA_WIDTH/8-1:0]                           request_strobe_i,
    input  logic                                              request_write_i,
    output logic                                              response_valid_o,
    input  logic                                              response_ready_i,
    output logic [  DATA_WIDTH-1:0]                           response_data_o,
    output logic [       BANKS-1:0]                           bank_request_valid_o,
    input  logic [       BANKS-1:0]                           bank_request_ready_i,
    output logic [       BANKS-1:0][          ADDR_WIDTH-1:0] bank_addr_o,
    output logic [       BANKS-1:0][    DATA_WIDTH/BANKS-1:0] bank_write_data_o,
    output logic [       BANKS-1:0][DATA_WIDTH/(8*BANKS)-1:0] bank_strobe_o,
    output logic [       BANKS-1:0]                           bank_write_o,
    input  logic [       BANKS-1:0]                           bank_response_valid_i,
    output logic [       BANKS-1:0]                           bank_response_ready_o,
    input  logic [       BANKS-1:0][    DATA_WIDTH/BANKS-1:0] bank_response_data_i
);
  logic [BANKS-1:0][0:0] s_response_user;
  memory_bank_adapter_detail #(
      .ADDR_WIDTH      (ADDR_WIDTH),
      .DATA_WIDTH      (DATA_WIDTH),
      .WRITE_USER_WIDTH(1),
      .READ_USER_WIDTH (1),
      .BANKS           (BANKS)
  ) u_detail (
      .clk_i,
      .rst_n_i,
      .clear_i,
      .request_valid_i,
      .request_ready_o,
      .request_addr_i,
      .request_write_data_i,
      .request_strobe_i,
      .request_user_i      (1'b0),
      .request_write_i,
      .response_valid_o,
      .response_ready_i,
      .response_data_o,
      .response_user_o     (s_response_user),
      .bank_request_valid_o,
      .bank_request_ready_i,
      .bank_addr_o,
      .bank_write_data_o,
      .bank_strobe_o,
      .bank_write_user_o   (),
      .bank_write_o,
      .bank_response_valid_i,
      .bank_response_ready_o,
      .bank_response_data_i,
      .bank_response_user_i('0)
  );
endmodule
