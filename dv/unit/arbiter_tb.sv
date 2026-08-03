// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module arbiter_tb;
  logic       clk = 0;
  logic       rst_n = 0;
  logic       advance;
  logic [3:0] request;
  logic [3:0] grant;
  logic [1:0] selected;
  logic       valid;
  always #5 clk = !clk;

  round_robin_arbiter #(
      .CLIENTS(4)
  ) u_arbiter (
      .clk_i     (clk),
      .rst_n_i   (rst_n),
      .advance_i (advance),
      .request_i (request),
      .grant_o   (grant),
      .selected_o(selected),
      .valid_o   (valid)
  );

  task automatic accept_and_expect(input logic [1:0] expected);
    @(negedge clk);
    #1;
    if (!valid || selected != expected || grant != (4'b0001 << expected)) begin
      $fatal(1, "arbiter expected %0d", expected);
    end
    advance = 1;
    @(negedge clk);
    advance = 0;
  endtask

  initial begin
    request = 0;
    advance = 0;
    repeat (2) @(negedge clk);
    rst_n   = 1;
    request = 4'b1111;
    accept_and_expect(0);
    accept_and_expect(1);
    accept_and_expect(2);
    accept_and_expect(3);
    request = 4'b0100;
    #1;
    if (!valid || selected != 2 || grant != 4'b0100) $fatal(1, "arbiter single request");
    $display("[PASS] arbiter_tb");
    $finish;
  end
endmodule
