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
  logic       phase_valid;
  logic       phase_ready;
  logic [7:0] phase_data;
  logic       phase_out_valid;
  logic       phase_out_ready;
  logic [7:0] phase_out_data;
  int         mailbox_transfers;
  int         fifo_transfers;
  int         phase_transfers;

  always #3 src_clk = !src_clk;
  always #5 dst_clk = !dst_clk;

  always @(posedge dst_clk) begin
    if (dst_valid && dst_ready) mailbox_transfers++;
    if (fifo_out_valid && fifo_out_ready) fifo_transfers++;
    if (phase_out_valid && phase_out_ready) phase_transfers++;
  end

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
  cdc_2phase #(
      .DATA_WIDTH(8)
  ) u_two_phase (
      .src_clk_i  (src_clk),
      .src_rst_n_i(src_rst_n),
      .src_data_i (phase_data),
      .src_valid_i(phase_valid),
      .src_ready_o(phase_ready),
      .dst_clk_i  (dst_clk),
      .dst_rst_n_i(dst_rst_n),
      .dst_data_o (phase_out_data),
      .dst_valid_o(phase_out_valid),
      .dst_ready_i(phase_out_ready)
  );

  initial begin
    src_valid         = 0;
    src_data          = 0;
    dst_ready         = 0;
    fifo_valid        = 0;
    fifo_data         = 0;
    fifo_out_ready    = 0;
    phase_valid       = 0;
    phase_data        = 0;
    phase_out_ready   = 0;
    mailbox_transfers = 0;
    fifo_transfers    = 0;
    phase_transfers   = 0;
    repeat (3) @(negedge src_clk);
    src_rst_n = 1;
    repeat (3) @(negedge dst_clk);
    dst_rst_n = 1;
    wait (src_ready && fifo_ready && phase_ready);

    // Keep ready high after the transfer. The four-phase request remains high
    // while it returns to zero, but the consumer must see exactly one item.
    @(negedge src_clk);
    src_data  = 8'ha5;
    src_valid = 1;
    @(negedge src_clk);
    src_valid = 0;
    wait (dst_valid);
    if (dst_data != 8'ha5) $fatal(1, "async mailbox data mismatch");
    dst_ready = 1;
    wait (mailbox_transfers == 1);
    repeat (5) @(posedge dst_clk);
    if (mailbox_transfers != 1 || dst_valid) $fatal(1, "async mailbox duplicate delivery");
    dst_ready = 0;

    @(negedge src_clk);
    phase_data  = 8'h3c;
    phase_valid = 1;
    @(negedge src_clk);
    phase_valid = 0;
    wait (phase_out_valid);
    if (phase_out_data != 8'h3c) $fatal(1, "two-phase data mismatch");
    phase_out_ready = 1;
    wait (phase_transfers == 1);
    @(negedge dst_clk);
    phase_out_ready = 0;

    // Resetting only the destination aborts a mailbox item rather than
    // delivering a stale request after reset release.
    wait (src_ready);
    @(negedge src_clk);
    src_data  = 8'hd4;
    src_valid = 1;
    @(negedge src_clk);
    src_valid = 0;
    wait (dst_valid);
    dst_rst_n = 0;
    #1;
    if (dst_valid) $fatal(1, "destination reset did not suppress mailbox valid");
    repeat (3) @(negedge dst_clk);
    dst_rst_n = 1;
    wait (src_ready);
    repeat (5) @(posedge dst_clk);
    if (mailbox_transfers != 1) $fatal(1, "mailbox delivered reset-aborted item");

    @(negedge src_clk);
    src_data  = 8'h96;
    src_valid = 1;
    @(negedge src_clk);
    src_valid = 0;
    wait (dst_valid);
    if (dst_data != 8'h96) $fatal(1, "mailbox did not recover after reset");
    dst_ready = 1;
    wait (mailbox_transfers == 2);
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
    fifo_out_ready = 1;
    wait (fifo_transfers == 1);
    fifo_out_ready = 0;

    // Resetting only the source flushes pending asynchronous FIFO data.
    wait (fifo_ready);
    @(negedge src_clk);
    fifo_data  = 8'h6b;
    fifo_valid = 1;
    @(negedge src_clk);
    fifo_valid = 0;
    wait (fifo_out_valid);
    src_rst_n = 0;
    #1;
    if (fifo_out_valid) $fatal(1, "source reset did not suppress FIFO valid");
    repeat (3) @(negedge src_clk);
    src_rst_n = 1;
    wait (fifo_ready);
    repeat (5) @(posedge dst_clk);
    if (fifo_transfers != 1) $fatal(1, "FIFO delivered reset-aborted item");
    $display("[PASS] cdc_tb");
    $finish;
  end
endmodule
