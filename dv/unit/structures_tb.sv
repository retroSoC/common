// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module structures_tb;
  logic clk = 1'b0;
  logic rst_n = 1'b0;
  logic clear;
  logic write_valid, write_ready;
  logic [1:0] write_tag;
  logic [7:0] write_data;
  logic read_request, read_take, read_ready, read_found;
  logic [1:0] read_tag;
  logic [7:0] read_data;
  logic [0:0][7:0] compare_data, compare_mask;
  logic [0:0] compare_valid, compare_found;
  logic tag_full, tag_empty;
  logic ring_write_valid, ring_write_ready, ring_read_valid, ring_read_ready, ring_retire;
  logic [7:0] ring_write_data, ring_read_data;
  logic [2:0] ring_read_addr, ring_write_ptr, ring_read_ptr;
  logic [3:0] ring_retire_count;
  logic ring_full, ring_empty;

  always #5 clk = !clk;

  tag_order_queue #(
      .DATA_WIDTH   (8),
      .TAG_WIDTH    (2),
      .CAPACITY     (4),
      .COMPARE_PORTS(1)
  ) u_tag_queue (
      .clk_i          (clk),
      .rst_n_i        (rst_n),
      .clear_i        (clear),
      .write_valid_i  (write_valid),
      .write_ready_o  (write_ready),
      .write_tag_i    (write_tag),
      .write_data_i   (write_data),
      .read_request_i (read_request),
      .read_tag_i     (read_tag),
      .read_take_i    (read_take),
      .read_ready_o   (read_ready),
      .read_found_o   (read_found),
      .read_data_o    (read_data),
      .compare_data_i (compare_data),
      .compare_mask_i (compare_mask),
      .compare_valid_i(compare_valid),
      .compare_found_o(compare_found),
      .full_o         (tag_full),
      .empty_o        (tag_empty)
  );
  circular_store #(
      .DATA_WIDTH(8),
      .DEPTH     (8)
  ) u_ring (
      .clk_i         (clk),
      .rst_n_i       (rst_n),
      .clear_i       (clear),
      .write_valid_i (ring_write_valid),
      .write_ready_o (ring_write_ready),
      .write_data_i  (ring_write_data),
      .read_valid_i  (ring_read_valid),
      .read_ready_o  (ring_read_ready),
      .read_addr_i   (ring_read_addr),
      .read_data_o   (ring_read_data),
      .retire_i      (ring_retire),
      .retire_count_i(ring_retire_count),
      .write_ptr_o   (ring_write_ptr),
      .read_ptr_o    (ring_read_ptr),
      .full_o        (ring_full),
      .empty_o       (ring_empty)
  );

  task automatic write_tagged(input logic [1:0] tag, input logic [7:0] data);
    begin
      @(negedge clk);
      write_tag   = tag;
      write_data  = data;
      write_valid = 1;
      @(negedge clk);
      write_valid = 0;
    end
  endtask

  initial begin
    clear             = 0;
    write_valid       = 0;
    write_tag         = 0;
    write_data        = 0;
    read_request      = 0;
    read_take         = 0;
    read_tag          = 0;
    compare_data[0]   = 0;
    compare_mask[0]   = 0;
    compare_valid     = 0;
    ring_write_valid  = 0;
    ring_write_data   = 0;
    ring_read_valid   = 0;
    ring_read_addr    = 0;
    ring_retire       = 0;
    ring_retire_count = 0;
    repeat (2) @(negedge clk);
    rst_n = 1;
    #1;
    if (!tag_empty || !ring_empty || !ring_write_ready) $fatal(1, "structure reset failed");
    write_tagged(2'd1, 8'h11);
    write_tagged(2'd2, 8'h21);
    write_tagged(2'd1, 8'h12);
    compare_data[0]  = 8'h12;
    compare_mask[0]  = 8'hff;
    compare_valid[0] = 1;
    #1;
    if (!compare_found[0]) $fatal(1, "tag queue comparison failed");
    read_tag     = 1;
    read_request = 1;
    #1;
    if (!read_found || read_data != 8'h11 || !read_ready) $fatal(1, "tag queue first head failed");
    @(negedge clk);
    read_take = 1;
    @(negedge clk);
    read_take = 0;
    #1;
    if (!read_found || read_data != 8'h12) $fatal(1, "tag queue FIFO ordering failed");
    read_tag = 2;
    #1;
    if (!read_found || read_data != 8'h21) $fatal(1, "tag queue independent tag failed");
    read_request  = 0;
    compare_valid = 0;
    for (int unsigned idx = 0; idx < 3; idx++) begin
      @(negedge clk);
      ring_write_valid = 1;
      ring_write_data  = 8'h80 + idx[7:0];
    end
    @(negedge clk);
    ring_write_valid = 0;
    ring_read_addr   = 1;
    ring_read_valid  = 1;
    #1;
    if (!ring_read_ready || ring_read_data != 8'h81 || ring_write_ptr != 3) begin
      $fatal(1, "circular store random read failed");
    end
    @(negedge clk);
    ring_read_valid   = 0;
    ring_retire       = 1;
    ring_retire_count = 2;
    @(negedge clk);
    ring_retire = 0;
    #1;
    if (ring_read_ptr != 2 || ring_empty) $fatal(1, "circular store retirement failed");
    $display("[PASS] structures_tb");
    $finish;
  end
endmodule
