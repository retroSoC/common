// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module cdc_tb;
  logic       src_clk = 0;
  logic       dst_clk = 0;
  logic       src_rst_n = 0;
  logic       dst_rst_n = 0;
  logic       src_valid;
  logic       src_ready;
  logic [7:0] src_data;
  logic       dst_valid;
  logic       dst_ready;
  logic [7:0] dst_data;
  logic       fifo_valid;
  logic       fifo_ready;
  logic [7:0] fifo_data;
  logic       fifo_out_valid;
  logic       fifo_out_ready;
  logic [7:0] fifo_out_data;

  always #3 src_clk = !src_clk;
  always #5 dst_clk = !dst_clk;

  async_reqack #(
      .DATA_WIDTH(8)
  ) u_mailbox (
      .src_clk_i  (src_clk),
      .src_rst_n_i(src_rst_n),
      .src_valid_i(src_valid),
      .src_ready_o(src_ready),
      .src_data_i (src_data),
      .dst_clk_i  (dst_clk),
      .dst_rst_n_i(dst_rst_n),
      .dst_valid_o(dst_valid),
      .dst_ready_i(dst_ready),
      .dst_data_o (dst_data)
  );
  async_gray_queue #(
      .DATA_WIDTH  (8),
      .BUFFER_DEPTH(4)
  ) u_queue (
      .src_clk_i  (src_clk),
      .src_rst_n_i(src_rst_n),
      .src_data_i (fifo_data),
      .src_valid_i(fifo_valid),
      .src_ready_o(fifo_ready),
      .dst_clk_i  (dst_clk),
      .dst_rst_n_i(dst_rst_n),
      .dst_data_o (fifo_out_data),
      .dst_valid_o(fifo_out_valid),
      .dst_ready_i(fifo_out_ready)
  );

  initial begin
    src_valid      = 0;
    src_data       = 0;
    dst_ready      = 0;
    fifo_valid     = 0;
    fifo_data      = 0;
    fifo_out_ready = 0;
    repeat (3) @(negedge src_clk);
    src_rst_n = 1;
    repeat (3) @(negedge dst_clk);
    dst_rst_n = 1;
    wait (src_ready);
    @(negedge src_clk);
    src_data  = 8'ha5;
    src_valid = 1;
    @(negedge src_clk);
    src_valid = 0;
    wait (dst_valid);
    if (dst_data != 8'ha5) $fatal(1, "async mailbox data mismatch");
    @(negedge dst_clk);
    dst_ready = 1;
    @(negedge dst_clk);
    dst_ready = 0;

    wait (fifo_ready);
    @(negedge src_clk);
    fifo_data  = 8'h5a;
    fifo_valid = 1;
    @(negedge src_clk);
    fifo_valid = 0;
    wait (fifo_out_valid);
    if (fifo_out_data != 8'h5a) $fatal(1, "async queue data mismatch");
    @(negedge dst_clk);
    fifo_out_ready = 1;
    @(negedge dst_clk);
    fifo_out_ready = 0;
    $display("[PASS] cdc_tb");
    $finish;
  end
endmodule
