// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module stream_control_tb;
  logic       clk = 1'b0;
  logic       rst_n = 1'b0;
  logic       flush;
  logic       drop_valid;
  logic       drop_ready;
  logic       discard;
  logic       drop_out_valid;
  logic       drop_out_ready;
  logic [1:0] limit;
  logic       submit_valid;
  logic       submit_ready;
  logic       forward_valid;
  logic       forward_ready;
  logic       retire;
  logic [1:0] used;

  always #5 clk = !clk;

  stream_discard_gate u_discard_gate (
      .in_valid_i (drop_valid),
      .in_ready_o (drop_ready),
      .discard_i  (discard),
      .out_valid_o(drop_out_valid),
      .out_ready_i(drop_out_ready)
  );
  stream_window_guard #(
      .MAX_INFLIGHT(2)
  ) u_window_guard (
      .clk_i          (clk),
      .rst_n_i        (rst_n),
      .flush_i        (flush),
      .limit_i        (limit),
      .submit_valid_i (submit_valid),
      .submit_ready_o (submit_ready),
      .forward_valid_o(forward_valid),
      .forward_ready_i(forward_ready),
      .retire_i       (retire),
      .used_o         (used)
  );

  task automatic submit_one;
    begin
      @(negedge clk);
      submit_valid = 1'b1;
      #1;
      if (!submit_ready || !forward_valid) $fatal(1, "window guard unexpectedly blocked request");
      @(negedge clk);
      submit_valid = 1'b0;
    end
  endtask

  initial begin
    flush          = 1'b0;
    drop_valid     = 1'b0;
    discard        = 1'b0;
    drop_out_ready = 1'b0;
    limit          = 2;
    submit_valid   = 1'b0;
    forward_ready  = 1'b1;
    retire         = 1'b0;

    repeat (2) @(negedge clk);
    rst_n      = 1'b1;

    drop_valid = 1'b1;
    #1;
    if (!drop_out_valid || drop_ready) $fatal(1, "discard gate pass-through contract failed");
    discard = 1'b1;
    #1;
    if (drop_out_valid || !drop_ready) $fatal(1, "discard gate did not consume input");
    discard        = 1'b0;
    drop_out_ready = 1'b1;
    #1;
    if (!drop_out_valid || !drop_ready) $fatal(1, "discard gate did not restore pass-through");
    drop_valid = 1'b0;

    submit_one();
    #1;
    if (used != 1) $fatal(1, "window guard did not count first request");
    submit_one();
    #1;
    if (used != 2) $fatal(1, "window guard did not count second request");

    submit_valid = 1'b1;
    #1;
    if (submit_ready || forward_valid) $fatal(1, "window guard exceeded configured limit");

    // A prior completion makes a slot available on the same edge.
    retire = 1'b1;
    #1;
    if (!submit_ready || !forward_valid)
      $fatal(1, "window guard missed same-cycle completion credit");
    @(negedge clk);
    submit_valid = 1'b0;
    retire       = 1'b0;
    #1;
    if (used != 2) $fatal(1, "simultaneous submit/retire changed occupancy");

    @(negedge clk);
    retire = 1'b1;
    @(negedge clk);
    retire = 1'b0;
    @(negedge clk);
    retire = 1'b1;
    @(negedge clk);
    retire = 1'b0;
    #1;
    if (used != 0) $fatal(1, "window guard did not retire requests");

    @(negedge clk);
    flush        = 1'b1;
    submit_valid = 1'b1;
    #1;
    if (submit_ready || forward_valid) $fatal(1, "window guard accepted request during flush");
    @(negedge clk);
    flush        = 1'b0;
    submit_valid = 1'b0;
    #1;
    if (used != 0) $fatal(1, "window guard flush did not clear occupancy");
    $display("[PASS] stream_control_tb");
    $finish;
  end
endmodule
