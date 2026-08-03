// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module clock_tb;
  logic       clk = 0;
  logic       rst_n = 0;
  logic       enable;
  logic [3:0] divisor;
  logic       divisor_valid;
  logic       divisor_ready;
  logic       divided_clk;
  logic [3:0] count;
  int         rising_edges;
  logic       clk0 = 0;
  logic       clk1 = 0;
  logic       mux_select;
  logic       mux_clk;
  int         mux_rising_edges;
  always #2 clk = !clk;
  always #3 clk0 = !clk0;
  always #5 clk1 = !clk1;
  always @(posedge divided_clk) rising_edges++;
  always @(posedge mux_clk) begin
    if (!clk0 && !clk1) $fatal(1, "clock mux generated a non-source edge");
    mux_rising_edges++;
  end

  clock_divider #(
      .DIV_WIDTH(4),
      .RESET_DIV(2)
  ) u_divider (
      .clk_i      (clk),
      .rst_n_i    (rst_n),
      .enable_i   (enable),
      .div_i      (divisor),
      .div_valid_i(divisor_valid),
      .div_ready_o(divisor_ready),
      .clk_o      (divided_clk),
      .count_o    (count)
  );
  safe_clock_mux u_mux (
      .clk0_i  (clk0),
      .clk1_i  (clk1),
      .rst_n_i (rst_n),
      .select_i(mux_select),
      .clk_o   (mux_clk)
  );

  initial begin
    enable           = 0;
    divisor          = 2;
    divisor_valid    = 0;
    rising_edges     = 0;
    mux_select       = 0;
    mux_rising_edges = 0;
    repeat (2) @(negedge clk);
    rst_n  = 1;
    enable = 1;
    repeat (12) @(posedge clk);
    if (rising_edges < 2) $fatal(1, "divider did not generate clock");
    wait (divisor_ready);
    @(negedge clk);
    divisor       = 3;
    divisor_valid = 1;
    @(negedge clk);
    divisor_valid = 0;
    repeat (8) @(posedge clk);
    if (count >= 3) $fatal(1, "divider counter range");
    enable = 0;
    @(negedge clk);
    if (divided_clk) $fatal(1, "disabled divider must be low");
    repeat (8) @(posedge clk0);
    if (mux_rising_edges == 0) $fatal(1, "clock mux did not select clk0");
    mux_select = 1;
    repeat (12) @(posedge clk1);
    if (mux_rising_edges < 2) $fatal(1, "clock mux did not complete handover");
    $display("[PASS] clock_tb");
    $finish;
  end
endmodule
