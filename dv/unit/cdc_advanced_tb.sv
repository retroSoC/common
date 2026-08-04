// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module cdc_advanced_tb;
  logic src_clk = 1'b0;
  logic dst_clk = 1'b0;
  logic src_rst_n = 1'b0;
  logic dst_rst_n = 1'b0;
  logic valid, ready;
  logic [7:0] data;
  logic out_valid, out_ready;
  logic [7:0] out_data;
  logic event_in, event_ready, event_busy, event_out;
  logic clear_src, clear_dst, clear_src_busy, clear_dst_busy;
  logic clear_ready, clear_valid;
  logic [7:0] clear_data, clear_out_data;
  logic event_count;
  int   mailbox_count;

  always #3 src_clk = !src_clk;
  always #5 dst_clk = !dst_clk;
  always @(posedge dst_clk) begin
    if (out_valid && out_ready) mailbox_count++;
    if (event_out) event_count <= ~event_count;
  end

  four_phase_mailbox #(
      .DATA_WIDTH(8)
  ) u_mailbox (
      .src_clk_i  (src_clk),
      .src_rst_n_i(src_rst_n),
      .src_valid_i(valid),
      .src_ready_o(ready),
      .src_data_i (data),
      .dst_clk_i  (dst_clk),
      .dst_rst_n_i(dst_rst_n),
      .dst_valid_o(out_valid),
      .dst_ready_i(out_ready),
      .dst_data_o (out_data)
  );
  cdc_event_bridge u_event (
      .src_clk_i     (src_clk),
      .src_rst_n_i   (src_rst_n),
      .event_i       (event_in),
      .source_ready_o(event_ready),
      .source_busy_o (event_busy),
      .dst_clk_i     (dst_clk),
      .dst_rst_n_i   (dst_rst_n),
      .event_o       (event_out)
  );
  clearable_two_phase_link #(
      .DATA_WIDTH (8),
      .SYNC_STAGES(3)
  ) u_clear_link (
      .src_clk_i       (src_clk),
      .src_rst_n_i     (src_rst_n),
      .src_clear_i     (clear_src),
      .src_clear_busy_o(clear_src_busy),
      .src_data_i      (clear_data),
      .src_valid_i     (clear_valid),
      .src_ready_o     (clear_ready),
      .dst_clk_i       (dst_clk),
      .dst_rst_n_i     (dst_rst_n),
      .dst_clear_i     (clear_dst),
      .dst_clear_busy_o(clear_dst_busy),
      .dst_data_o      (clear_out_data),
      .dst_valid_o     (),
      .dst_ready_i     (1'b1)
  );

  initial begin
    valid         = 0;
    data          = 0;
    out_ready     = 0;
    event_in      = 0;
    clear_src     = 0;
    clear_dst     = 0;
    clear_data    = 0;
    clear_valid   = 0;
    mailbox_count = 0;
    event_count   = 0;
    repeat (3) @(negedge src_clk);
    src_rst_n = 1;
    repeat (3) @(negedge dst_clk);
    dst_rst_n = 1;
    wait (ready && event_ready && clear_ready);
    @(negedge src_clk);
    data  = 8'h5a;
    valid = 1;
    @(negedge src_clk);
    valid = 0;
    wait (out_valid);
    if (out_data != 8'h5a) $fatal(1, "four phase mailbox data failed");
    out_ready = 1;
    wait (mailbox_count == 1);
    repeat (4) @(posedge dst_clk);
    if (mailbox_count != 1) $fatal(1, "four phase mailbox duplicated data");
    out_ready = 0;
    wait (event_ready);
    @(negedge src_clk);
    event_in = 1;
    @(negedge src_clk);
    event_in = 0;
    wait (event_out);
    repeat (3) @(posedge dst_clk);
    if (event_count != 1'b1) $fatal(1, "event bridge failed");
    @(negedge src_clk);
    clear_src = 1;
    #1;
    if (!clear_src_busy || clear_ready) $fatal(1, "clearable link did not isolate source");
    @(negedge src_clk);
    clear_src = 0;
    wait (!clear_src_busy && !clear_dst_busy && clear_ready);
    // A destination-domain one-cycle request must be retained until the
    // source coordinator accepts it; a plain synchronized pulse could be lost.
    @(negedge dst_clk);
    clear_dst = 1;
    #1;
    if (!clear_dst_busy) $fatal(1, "destination clear did not isolate immediately");
    @(negedge dst_clk);
    clear_dst = 0;
    wait (clear_src_busy);
    wait (!clear_src_busy && !clear_dst_busy && clear_ready);
    $display("[PASS] cdc_advanced_tb");
    $finish;
  end
endmodule
