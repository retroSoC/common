// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

`timescale 1ns / 1ps

module clk_int_div_simple_tb ();
  logic rst_n_i, clk_i;
  logic clk_o, div_i;
  logic s_ready, s_done;
  logic s_valid_d, s_valid_q;
  logic [3:0] s_cnt_d, s_cnt_q;
  logic [31:0] r_div;
  always #5.000 clk_i <= ~clk_i;

  initial begin
    clk_i   = 1'b0;
    rst_n_i = 1'b0;
    // wait for a while to release reset signal
    // repeat (4096) @(posedge clk_i);
    repeat (40) @(posedge clk_i);
    #100 rst_n_i = 1;
    //    #30 div_i = 32'd16;
  end

  assign s_cnt_d = s_cnt_q + 1'b1;
  dffr #(4) u_test_dffr (
      clk_i,
      rst_n_i,
      s_cnt_d,
      s_cnt_q
  );

  initial begin
    if ($test$plusargs("dump_fst_wave")) begin
      $dumpfile("sim.wave");
      $dumpvars(0, clk_int_div_simple_tb);
    end else if ($test$plusargs("default_args")) begin
      $display("=========sim default args===========");
    end
    $display("sim 11000ns");
    #11000 $finish;
  end

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (~rst_n_i) begin
      r_div <= 32'd4;
    end
    // end else if (s_cnt_q == 4'hF && s_valid_q) begin
    //   r_div <= r_div + 2'd2;
    // end
  end

  always_comb begin
    s_valid_d = 1'b0;
    if (s_done) begin
      s_valid_d = 1'b1;
    end
  end

  dffr #(1) u_valid_dffr (
      clk_i,
      rst_n_i,
      s_valid_d,
      s_valid_q
  );


  clk_int_div_simple u_clk_int_even_simple (
      clk_i,
      rst_n_i,
      r_div,
      s_valid_q,
      s_ready,
      s_done,
      clk_o
  );

endmodule
