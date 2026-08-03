// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module cdc_flush_tb;
  logic       src_clk = 1'b0;
  logic       dst_clk = 1'b0;
  logic       src_rst_n = 1'b0;
  logic       dst_rst_n = 1'b0;
  logic       two_clear;
  logic       two_busy_src;
  logic       two_busy_dst;
  logic [7:0] two_data;
  logic       two_valid;
  logic       two_ready;
  logic [7:0] two_out_data;
  logic       two_out_valid;
  logic       two_out_ready;
  logic       fifo_clear;
  logic       fifo_busy_src;
  logic       fifo_busy_dst;
  logic [7:0] fifo_data;
  logic       fifo_valid;
  logic       fifo_ready;
  logic [7:0] fifo_out_data;
  logic       fifo_out_valid;
  logic       fifo_out_ready;
  int         two_transfers;
  int         fifo_transfers;

  always #3 src_clk = !src_clk;
  always #5 dst_clk = !dst_clk;

  always @(posedge dst_clk) begin
    if (two_out_valid && two_out_ready) two_transfers++;
    if (fifo_out_valid && fifo_out_ready) fifo_transfers++;
  end

  cdc_2phase_warm_flush #(
      .DATA_WIDTH(8)
  ) u_two_phase (
      .src_clk_i       (src_clk),
      .src_rst_n_i     (src_rst_n),
      .src_clear_i     (two_clear),
      .src_clear_busy_o(two_busy_src),
      .src_data_i      (two_data),
      .src_valid_i     (two_valid),
      .src_ready_o     (two_ready),
      .dst_clk_i       (dst_clk),
      .dst_rst_n_i     (dst_rst_n),
      .dst_clear_busy_o(two_busy_dst),
      .dst_data_o      (two_out_data),
      .dst_valid_o     (two_out_valid),
      .dst_ready_i     (two_out_ready)
  );
  cdc_fifo_warm_flush #(
      .DATA_WIDTH  (8),
      .BUFFER_DEPTH(4)
  ) u_fifo (
      .src_clk_i       (src_clk),
      .src_rst_n_i     (src_rst_n),
      .src_clear_i     (fifo_clear),
      .src_clear_busy_o(fifo_busy_src),
      .src_data_i      (fifo_data),
      .src_valid_i     (fifo_valid),
      .src_ready_o     (fifo_ready),
      .dst_clk_i       (dst_clk),
      .dst_rst_n_i     (dst_rst_n),
      .dst_clear_busy_o(fifo_busy_dst),
      .dst_data_o      (fifo_out_data),
      .dst_valid_o     (fifo_out_valid),
      .dst_ready_i     (fifo_out_ready)
  );

  task automatic send_two(input logic [7:0] value);
    begin
      wait (two_ready && !two_busy_src);
      @(negedge src_clk);
      two_data  = value;
      two_valid = 1'b1;
      @(negedge src_clk);
      two_valid = 1'b0;
    end
  endtask

  task automatic send_fifo(input logic [7:0] value);
    begin
      wait (fifo_ready && !fifo_busy_src);
      @(negedge src_clk);
      fifo_data  = value;
      fifo_valid = 1'b1;
      @(negedge src_clk);
      fifo_valid = 1'b0;
    end
  endtask

  initial begin
    two_clear      = 1'b0;
    two_data       = '0;
    two_valid      = 1'b0;
    two_out_ready  = 1'b0;
    fifo_clear     = 1'b0;
    fifo_data      = '0;
    fifo_valid     = 1'b0;
    fifo_out_ready = 1'b0;
    two_transfers  = 0;
    fifo_transfers = 0;
    repeat (3) @(negedge src_clk);
    src_rst_n = 1'b1;
    repeat (3) @(negedge dst_clk);
    dst_rst_n = 1'b1;

    send_two(8'ha1);
    wait (two_out_valid);
    if (two_out_data != 8'ha1) $fatal(1, "two-phase normal data mismatch");
    two_out_ready = 1'b1;
    wait (two_transfers == 1);
    two_out_ready = 1'b0;

    // The retained item is deliberately cancelled by the warm flush.
    send_two(8'hb2);
    wait (two_out_valid);
    @(negedge src_clk);
    two_clear = 1'b1;
    @(negedge src_clk);
    two_clear = 1'b0;
    wait (two_busy_src);
    #1;
    if (two_ready) $fatal(1, "two-phase source was not isolated during clear");
    wait (!two_busy_src && !two_busy_dst);
    two_out_ready = 1'b1;
    repeat (12) @(posedge dst_clk);
    if (two_transfers != 1) $fatal(1, "warm flush delivered cancelled two-phase item");
    two_out_ready = 1'b0;
    send_two(8'hc3);
    wait (two_out_valid);
    if (two_out_data != 8'hc3) $fatal(1, "two-phase post-flush data mismatch");
    two_out_ready = 1'b1;
    wait (two_transfers == 2);
    two_out_ready = 1'b0;

    send_fifo(8'hd4);
    wait (fifo_out_valid);
    @(negedge src_clk);
    fifo_clear = 1'b1;
    @(negedge src_clk);
    fifo_clear = 1'b0;
    wait (fifo_busy_src);
    wait (!fifo_busy_src && !fifo_busy_dst);
    fifo_out_ready = 1'b1;
    repeat (12) @(posedge dst_clk);
    if (fifo_transfers != 0) $fatal(1, "warm flush delivered cancelled FIFO item");
    fifo_out_ready = 1'b0;
    send_fifo(8'he5);
    wait (fifo_out_valid);
    if (fifo_out_data != 8'he5) $fatal(1, "FIFO post-flush data mismatch");
    fifo_out_ready = 1'b1;
    wait (fifo_transfers == 1);
    $display("[PASS] cdc_flush_tb");
    $finish;
  end
endmodule
