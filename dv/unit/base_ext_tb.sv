// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module base_ext_tb;
  logic       clk = 1'b0;
  logic       rst_n = 1'b0;
  logic       flush;
  logic [3:0] touch;
  logic [3:0] victim;
  logic       clear_value;
  logic       clear_peak;
  logic       enable;
  logic       load;
  logic       subtract;
  logic [3:0] step;
  logic [3:0] load_value;
  logic [3:0] value;
  logic [3:0] peak;
  logic       value_overflow;
  logic       peak_overflow;

  always #5 clk = !clk;

  plru_victim_selector #(
      .WAYS(4)
  ) u_plru (
      .clk_i   (clk),
      .rst_n_i (rst_n),
      .flush_i (flush),
      .touch_i (touch),
      .victim_o(victim)
  );
  peak_delta_counter #(
      .DATA_WIDTH(4)
  ) u_peak_counter (
      .clk_i           (clk),
      .rst_n_i         (rst_n),
      .flush_i         (flush),
      .clear_value_i   (clear_value),
      .clear_peak_i    (clear_peak),
      .enable_i        (enable),
      .load_i          (load),
      .subtract_i      (subtract),
      .step_i          (step),
      .load_value_i    (load_value),
      .value_o         (value),
      .peak_o          (peak),
      .value_overflow_o(value_overflow),
      .peak_overflow_o (peak_overflow)
  );

  task automatic touch_way(input logic [3:0] onehot_way);
    begin
      @(negedge clk);
      touch = onehot_way;
      @(negedge clk);
      touch = '0;
    end
  endtask

  initial begin
    flush       = 1'b0;
    touch       = '0;
    clear_value = 1'b0;
    clear_peak  = 1'b0;
    enable      = 1'b0;
    load        = 1'b0;
    subtract    = 1'b0;
    step        = '0;
    load_value  = '0;
    repeat (2) @(negedge clk);
    rst_n = 1'b1;
    #1;
    if (victim != 4'b0001) $fatal(1, "PLRU reset victim is not deterministic");

    touch_way(4'b0001);
    #1;
    if (victim != 4'b0100) $fatal(1, "PLRU did not move away from touched way zero");
    touch_way(4'b0100);
    #1;
    if (victim != 4'b0010) $fatal(1, "PLRU tree traversal is incorrect");
    if ((victim & (victim - 1'b1)) != 0) $fatal(1, "PLRU victim is not one-hot");

    @(negedge clk);
    enable = 1'b1;
    step   = 3;
    @(negedge clk);
    #1;
    if (value != 3 || peak != 3) $fatal(1, "peak counter first increment failed");
    step = 5;
    @(negedge clk);
    #1;
    if (value != 8 || peak != 8) $fatal(1, "peak counter did not track higher value");
    subtract = 1'b1;
    step     = 2;
    @(negedge clk);
    enable   = 1'b0;
    subtract = 1'b0;
    #1;
    if (value != 6 || peak != 8) $fatal(1, "peak counter regressed after decrement");

    @(negedge clk);
    clear_peak = 1'b1;
    @(negedge clk);
    clear_peak = 1'b0;
    #1;
    if (peak != 0 || peak_overflow) $fatal(1, "peak clear failed");
    @(negedge clk);
    load       = 1'b1;
    load_value = 9;
    @(negedge clk);
    load = 1'b0;
    #1;
    if (value != 9 || peak != 9) $fatal(1, "peak counter load failed");
    @(negedge clk);
    enable = 1'b1;
    step   = 8;
    @(negedge clk);
    enable = 1'b0;
    #1;
    if (value != 1 || !value_overflow || peak != 1 || !peak_overflow) begin
      $fatal(1, "peak counter extended overflow tracking failed");
    end
    $display("[PASS] base_ext_tb");
    $finish;
  end
endmodule
