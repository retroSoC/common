// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module fifo_tb;
  logic       clk = 1'b0;
  logic       rst_n = 1'b0;
  logic       flush;
  logic       push;
  logic       full;
  logic [7:0] data_in;
  logic       pop;
  logic       empty;
  logic [7:0] data_out;
  logic [2:0] count;

  always #5 clk = !clk;

  fifo #(
      .DATA_WIDTH  (8),
      .BUFFER_DEPTH(4)
  ) u_fifo (
      .clk_i  (clk),
      .rst_n_i(rst_n),
      .flush_i(flush),
      .push_i (push),
      .full_o (full),
      .dat_i  (data_in),
      .pop_i  (pop),
      .empty_o(empty),
      .dat_o  (data_out),
      .cnt_o  (count)
  );

  task automatic push_word(input logic [7:0] word);
    @(negedge clk);
    push    = 1'b1;
    data_in = word;
    pop     = 1'b0;
    @(negedge clk);
    push = 1'b0;
  endtask

  task automatic pop_word(input logic [7:0] word);
    @(negedge clk);
    if (data_out !== word) $fatal(1, "fifo expected %h got %h", word, data_out);
    pop = 1'b1;
    @(negedge clk);
    pop = 1'b0;
  endtask

  initial begin
    flush   = 0;
    push    = 0;
    pop     = 0;
    data_in = '0;
    repeat (2) @(negedge clk);
    rst_n = 1;
    push_word(8'h11);
    push_word(8'h22);
    push_word(8'h33);
    push_word(8'h44);
    if (!full || count != 4) $fatal(1, "fifo did not fill");
    @(negedge clk);
    if (data_out != 8'h11) $fatal(1, "fifo head incorrect");
    push    = 1;
    pop     = 1;
    data_in = 8'h55;
    @(negedge clk);
    push = 0;
    pop  = 0;
    if (count != 4 || data_out != 8'h22) $fatal(1, "full pop/push throughput failed");
    pop_word(8'h22);
    pop_word(8'h33);
    pop_word(8'h44);
    pop_word(8'h55);
    if (!empty || count != 0 || data_out != 0) $fatal(1, "fifo did not drain");
    $display("[PASS] fifo_tb");
    $finish;
  end
endmodule
