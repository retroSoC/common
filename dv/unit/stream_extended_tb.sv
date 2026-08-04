// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module stream_extended_tb;
  logic clk = 1'b0;
  logic rst_n = 1'b0;
  logic flush;
  logic q_valid, q_ready, q_out_valid, q_out_ready;
  logic [7:0] q_data, q_out_data;
  logic [2:0] q_usage;
  logic latest_valid, latest_out_valid, latest_out_ready, latest_busy;
  logic [7:0] latest_data, latest_out_data;
  logic [1:0] x_valid, x_ready, x_out_valid, x_out_ready;
  logic [1:0][7:0] x_data, x_out_data;
  logic [1:0][0:0] x_target, x_source;
  int x_transfers;

  always #5 clk = !clk;
  always @(posedge clk) if (x_out_valid[0] && x_out_ready[0]) x_transfers++;

  stream_queue #(
      .DATA_WIDTH  (8),
      .DEPTH       (4),
      .FALL_THROUGH(1'b1)
  ) u_queue (
      .clk_i      (clk),
      .rst_n_i    (rst_n),
      .flush_i    (flush),
      .in_valid_i (q_valid),
      .in_ready_o (q_ready),
      .in_data_i  (q_data),
      .out_valid_o(q_out_valid),
      .out_ready_i(q_out_ready),
      .out_data_o (q_out_data),
      .usage_o    (q_usage)
  );
  latest_value_stream #(
      .DATA_WIDTH(8)
  ) u_latest (
      .clk_i      (clk),
      .rst_n_i    (rst_n),
      .clear_i    (flush),
      .in_valid_i (latest_valid),
      .in_data_i  (latest_data),
      .out_valid_o(latest_out_valid),
      .out_ready_i(latest_out_ready),
      .out_data_o (latest_out_data),
      .busy_o     (latest_busy)
  );
  stream_crossbar #(
      .DATA_WIDTH(8),
      .INPUTS    (2),
      .OUTPUTS   (2)
  ) u_crossbar (
      .clk_i      (clk),
      .rst_n_i    (rst_n),
      .clear_i    (flush),
      .in_valid_i (x_valid),
      .in_ready_o (x_ready),
      .in_data_i  (x_data),
      .target_i   (x_target),
      .out_valid_o(x_out_valid),
      .out_ready_i(x_out_ready),
      .out_data_o (x_out_data),
      .source_o   (x_source)
  );

  initial begin
    flush            = 0;
    q_valid          = 0;
    q_data           = 0;
    q_out_ready      = 0;
    latest_valid     = 0;
    latest_data      = 0;
    latest_out_ready = 0;
    x_valid          = '0;
    x_data           = '0;
    x_target         = '0;
    x_out_ready      = '0;
    x_transfers      = 0;
    repeat (2) @(negedge clk);
    rst_n       = 1;
    // Empty fall-through transfer must not consume storage.
    q_data      = 8'h11;
    q_valid     = 1;
    q_out_ready = 1;
    #1;
    if (!q_out_valid || q_out_data != 8'h11 || !q_ready) $fatal(1, "fall-through queue failed");
    @(negedge clk);
    q_valid     = 0;
    q_out_ready = 0;
    #1;
    if (q_usage != 0 || q_out_valid) $fatal(1, "fall-through queue left phantom entry");
    q_data  = 8'h21;
    q_valid = 1;
    @(negedge clk);
    q_data = 8'h22;
    @(negedge clk);
    q_valid = 0;
    #1;
    if (q_usage != 2 || q_out_data != 8'h21) $fatal(1, "queue retention failed");
    q_out_ready = 1;
    @(negedge clk);
    #1;
    if (q_out_data != 8'h22) $fatal(1, "queue order failed");
    @(negedge clk);
    q_out_ready  = 0;
    latest_data  = 8'h31;
    latest_valid = 1;
    @(negedge clk);
    latest_data = 8'h32;
    @(negedge clk);
    latest_data = 8'h33;
    @(negedge clk);
    latest_valid = 0;
    #1;
    if (!latest_out_valid || latest_out_data != 8'h31 || !latest_busy) begin
      $fatal(1, "latest-value head retention failed");
    end
    latest_out_ready = 1;
    @(negedge clk);
    #1;
    if (!latest_out_valid || latest_out_data != 8'h33) $fatal(1, "latest value overwrite failed");
    @(negedge clk);
    latest_out_ready = 0;
    // Two contenders for output zero: source zero wins first, and arbitration
    // must remain locked while that output is stalled.
    x_valid          = 2'b11;
    x_data[0]        = 8'ha0;
    x_data[1]        = 8'hb0;
    x_target         = 2'b00;
    @(negedge clk);
    #1;
    if (!x_out_valid[0] || x_out_data[0] != 8'ha0 || x_source[0] != 0) begin
      $fatal(1, "crossbar initial arbitration failed");
    end
    x_data[1] = 8'hbf;
    #1;
    if (x_out_data[0] != 8'ha0 || x_source[0] != 0) $fatal(1, "crossbar lock failed");
    x_out_ready[0] = 1;
    @(negedge clk);
    x_valid[0]     = 0;
    x_out_ready[0] = 0;
    #1;
    if (!x_out_valid[0] || x_out_data[0] != 8'hbf || x_source[0] != 1 || x_transfers != 1) begin
      $fatal(1, "crossbar fairness or handoff failed");
    end
    x_out_ready = '0;
    x_valid     = '0;
    flush       = 1;
    #1;
    if (q_ready || q_out_valid) $fatal(1, "queue flush handshake failed");
    $display("[PASS] stream_extended_tb");
    $finish;
  end
endmodule
